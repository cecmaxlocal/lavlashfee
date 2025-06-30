Of course. Here is a comprehensive script and explanation for measuring price gaps, often called "Level Gaps," designed for the TradingView platform using its Pine Script language.

This script will:
1.  **Identify** both "Gap Ups" and "Gap Downs."
2.  **Measure** the size of the gap in both points (price) and percentage.
3.  **Visualize** the gap on the chart using colored boxes.
4.  **Label** the gap with its size information.
5.  **Extend** the visualization of the gap into the future until the price "fills" it, a key concept in gap trading.

---

### What is a Price Gap?

A price gap occurs when there is a significant difference between one trading period's closing price and the next period's opening price, with no trading occurring in between.

*   **Gap Up:** The current bar's `low` is higher than the previous bar's `high`. This indicates strong bullish sentiment.
*   **Gap Down:** The current bar's `high` is lower than the previous bar's `low`. This indicates strong bearish sentiment.

Traders watch these gaps closely as they often act as powerful support or resistance levels. The saying "gaps tend to get filled" refers to the price eventually returning to cover the empty range of the gap.

---

### TradingView Pine Script: Measure Level Gaps

This script is a powerful indicator that you can copy and paste directly into the Pine Editor in TradingView.

```pinescript
//@version=5
indicator("Measure Level Gaps", "Gaps", overlay=true, max_boxes_count=500, max_labels_count=500)

// --- USER INPUTS ---
// These settings allow you to customize the indicator's behavior from the settings menu.
group_visuals = "Visual Settings"
inp_show_boxes = input.bool(true, "Show Gap Boxes", group=group_visuals)
inp_extend_gaps = input.bool(true, "Extend Unfilled Gaps", group=group_visuals, tooltip="Extends the gap box to the right until the price action 'fills' the gap.")
inp_up_color = input.color(color.new(color.green, 80), "Gap Up Color", group=group_visuals)
inp_down_color = input.color(color.new(color.red, 80), "Gap Down Color", group=group_visuals)

group_labels = "Label Settings"
inp_show_labels = input.bool(true, "Show Gap Labels", group=group_labels)
inp_label_size = input.string("small", "Label Size", options=["tiny", "small", "normal", "large", "huge"], group=group_labels)

group_filters = "Filter Settings"
inp_min_gap_pct = input.float(0.1, "Minimum Gap Percentage (%)", minval=0, step=0.1, group=group_filters, tooltip="Only show gaps that are at least this percentage of the previous bar's closing price.")
inp_max_gaps = input.int(50, "Max Number of Gaps to Show", minval=1, maxval=500, group=group_filters, tooltip="Limits the number of historical gaps drawn on the chart to improve performance.")

// --- VARIABLE DECLARATION ---
// 'var' ensures these arrays persist across all bars of the chart's history.
var box[]   arr_gap_boxes = array.new_box()
var label[] arr_gap_labels = array.new_label()
var bool[]  arr_is_gap_up = array.new_bool() // To track the direction of each gap

// --- CORE GAP DETECTION & MEASUREMENT LOGIC ---
// Define previous bar's high and low for comparison.
float prev_high = high[1]
float prev_low = low[1]
float prev_close = close[1]

// Check for gap conditions on the current bar.
bool is_gap_up = low > prev_high
bool is_gap_down = high < prev_low

// --- GAP PROCESSING ---
// This block only runs on bars where a new gap is detected.
if is_gap_up or is_gap_down
    // Calculate the size of the gap in points and percentage.
    float gap_size_points = is_gap_up ? low - prev_high : prev_low - high
    float gap_size_percent = (gap_size_points / prev_close) * 100

    // Only proceed if the gap meets the minimum percentage requirement.
    if gap_size_percent >= inp_min_gap_pct
        // Define the price levels (top and bottom) of the gap.
        float gap_top = is_gap_up ? low : prev_low
        float gap_bottom = is_gap_up ? prev_high : high
        
        // Define box color based on gap direction.
        color box_color = is_gap_up ? inp_up_color : inp_down_color
        
        // --- CREATE VISUALS (BOXES AND LABELS) ---
        // Create the box to visualize the gap area.
        if inp_show_boxes
            // The box starts from the previous bar and ends at the open of the current bar.
            box new_box = box.new(time[1], gap_top, time, gap_bottom,
                 border_color=na, 
                 bgcolor=box_color,
                 extend=inp_extend_gaps ? extend.right : extend.none)
            array.push(arr_gap_boxes, new_box)
            array.push(arr_is_gap_up, is_gap_up) // Store the direction for the fill check

        // Create the label with measurement info.
        if inp_show_labels
            string label_text = (is_gap_up ? "Gap Up\n" : "Gap Down\n") + 
                                str.tostring(gap_size_points, format.mintick) + " (" + 
                                str.tostring(gap_size_percent, "0.##") + "%)"
            
            label new_label = label.new(time, (gap_top + gap_bottom) / 2, label_text, 
                 color=color.new(color.white, 20), 
                 textcolor=is_gap_up ? color.green : color.red, 
                 style=label.style_label_left, 
                 size=inp_label_size)
            array.push(arr_gap_labels, new_label)

// --- GARBAGE COLLECTION: MANAGE OLD GAPS ---
// Prevents the script from slowing down by removing the oldest gaps if we exceed the max limit.
while array.size(arr_gap_boxes) > inp_max_gaps
    box.delete(array.shift(arr_gap_boxes))
    array.shift(arr_is_gap_up)
while array.size(arr_gap_labels) > inp_max_gaps
    label.delete(array.shift(arr_gap_labels))


// --- GAP FILL LOGIC ---
// This section checks if any of the extended, unfilled gaps have been filled by the current price action.
if inp_extend_gaps and array.size(arr_gap_boxes) > 0
    // We loop backwards because we might be modifying the box's properties.
    for i = array.size(arr_gap_boxes) - 1 to 0
        box current_box = array.get(arr_gap_boxes, i)
        
        // A gap is considered "unfilled" if its right edge is still being extended.
        // We check this by seeing if the box's right time coordinate is beyond the current bar.
        if box.get_right(current_box) >= time
            bool gap_is_up = array.get(arr_is_gap_up, i)
            float gap_top_price = box.get_top(current_box)
            float gap_bottom_price = box.get_bottom(current_box)
            
            // Check for fill condition.
            bool is_filled = false
            if gap_is_up and low <= gap_bottom_price // A gap up is filled if price drops to its bottom edge.
                is_filled := true
            else if not gap_is_up and high >= gap_top_price // A gap down is filled if price rises to its top edge.
                is_filled := true
            
            // If the gap is now filled, we stop extending it by setting its right edge to the current bar's time.
            if is_filled
                box.set_right(current_box, time)
```

---

### How to Use the Script

1.  **Open TradingView**: Go to any chart (e.g., BTCUSD, AAPL, EURUSD).
2.  **Open Pine Editor**: Click the "Pine Editor" tab at the bottom of the chart.
3.  **Paste the Code**: Delete any existing code in the editor and paste the entire script from above.
4.  **Add to Chart**: Click the "Add to Chart" button.
5.  **Configure**: The indicator will appear on your chart. You can click the settings icon (⚙️) next to the indicator's name on the chart to customize its inputs.

### Features and Settings Explained

*   **Show Gap Boxes**: Toggles the visibility of the colored rectangles that highlight the gap area.
*   **Extend Unfilled Gaps**: This is a key feature. When enabled, the gap box will extend to the right indefinitely until the price action "fills" the gap, at which point the extension stops. This provides a powerful visual for support/resistance levels.
*   **Gap Up/Down Color**: Customize the colors for bullish and bearish gaps.
*   **Show Gap Labels**: Toggles the visibility of the text labels that show the gap's size.
*   **Minimum Gap Percentage (%)**: This is a crucial filter. It prevents the chart from being cluttered with tiny, insignificant gaps. For example, a setting of `0.5` will only show gaps that are 0.5% or larger than the previous day's close.
*   **Max Number of Gaps to Show**: Limits how many historical gaps are drawn to maintain good chart performance.