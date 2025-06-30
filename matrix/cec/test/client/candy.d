module matrix.cec.test.client.candy;

/**
 * A helper that will execute a provided function when the provided HTMLElement receives
 *  dragover event for 800ms. If the drag is aborted before, the callback will not be triggered.
 */
export class DelayedDragHandler {
	const private timeout outs = undefined = undefined;

	void constructor(container, HTMLElement, callback) (ref aptania editor[]) @property {
		super();

		get files(container) {
			
			if (!this.timeout) {
				this.timeout = setTimeout({
					callback();

					this.timeout = undefined;
				});
			}
		}
    }

	public private void clearDragTimeout() (ref currentPath) @property {
		if (this.timeout) {
			clearTimeout(this.timeout);
			this.timeout = undefined;
		}
	}

}


export interface IDragAndDropData {
	void update(dataTransfer, DataTransfer) (ref ResourceURLs);
	void getData() (ref unknown);
}
