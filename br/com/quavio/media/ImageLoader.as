package br.com.quavio.media
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ImageLoader extends MovieClip 
	{
		private var m_loader: Loader = new Loader();
		private var m_callback: Function;
		private var m_tag: Object;
		
		public function ImageLoader(): void 
		{
		}
		
		/*
		 * Tag to associate with the loader instance
		 */
		public function set tag(_data: Object):void 
		{
			this.m_tag = _data;
		}
		
		public function load(
			_sImageUrl: String,
			_callback: Function):void 
		{
			this.m_callback = _callback;
			this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

			this.m_loader.load(new URLRequest(_sImageUrl));
		}
		
		private function onImageLoaded(e: Event):void 
		{
			var clip: MovieClip = new MovieClip();
			var ldrInfo: LoaderInfo = e.currentTarget as LoaderInfo;
			clip.addChild(ldrInfo.loader);
			
			// return the image clip and the tag
			this.m_callback(clip, this.m_tag);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
            trace("Failed to load image: " + this.m_tag);
			this.m_callback(null, this.m_tag);
        }
	}
}