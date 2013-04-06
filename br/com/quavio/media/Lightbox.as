package br.com.quavio.media {
	import br.com.quavio.display.QuavioMovieClip;
	import br.com.quavio.media.*;
	import flash.display.*;
	import flash.events.*;
	import com.gfx.SnakeCircle;
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import flash.utils.Timer;


	/**
	 * ...
	 * @author Felipe Lima
	 */
	public class Lightbox extends MovieClip
	{
		private var imageText: String;
		private var ofText: String;
		private var lstImages: Array = [];
		private var currIndex: int = -1;
		private var totalImages: uint = 0;
		private var imagesLoaded: uint = 0;
		private var linkToVisit: String;
		private static const arrowMargin: uint = 10;
		private static const borderSize: uint = 15;
		private static const elemsMargin: uint = 10;
		private static const lowerPanelSize: uint = 50;
		private static const bgInitialSize: uint = 430;
		private var mcOverlay: MovieClip = new MovieClip();
		private var snakeLoader: SnakeCircle = new SnakeCircle(15, 3, 0xFFFFFF, 10);

		public function Lightbox(
			_sTitle: String,
			_sLinkToVisit: String = null,
			_sImageText: String = "Imagem",
			_sOfText: String = "de") {

			imageText = _sImageText;
			ofText = _sOfText;
			linkToVisit = _sLinkToVisit;

			_btnPrev.addEventListener(MouseEvent.CLICK, function(e: Event) { goPrev(); } );
			_btnNext.addEventListener(MouseEvent.CLICK, function(e: Event) { goNext(); } );
			_btnClose.addEventListener(MouseEvent.CLICK, function(e: Event) { hide(); } );

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_btnClose.buttonMode = true;
			_btnPrev.buttonMode = true;
			_btnNext.buttonMode = true;
			_btnAcesse.visible = false;

			_txtClientName.text = _sTitle;
			this.alpha = 0;
		}

		function onAddedToStage(e: Event):void {
			stage.addEventListener(Event.RESIZE, centerLightbox);
			stage.addEventListener(Event.RESIZE, addTranspOverlay);
			stage.addChildAt(mcOverlay, stage.getChildIndex(this));

			var nStageLeft: int = (Document.StageOrigWidth - stage.stageWidth) / 2,
				nStageTop: int = (Document.StageOrigHeight - stage.stageHeight) / 2;

			this.x = nStageLeft + (stage.stageWidth / 2) - (_bg.width / 2);
			this.y = nStageTop + (stage.stageHeight / 2) - (_bg.height / 2);

			_bg.addChild(snakeLoader);
			snakeLoader.x = (_bg.width / 2) - (snakeLoader.width / 2);
			snakeLoader.y = (_bg.height / 2) - (snakeLoader.height / 2);
			snakeLoader.start();
		}

		public function show(_lstImages: Array):void {
			TweenLite.to(this, 0.5, { alpha: 1});

			centerLightbox(null);
			addTranspOverlay(null);

			lstImages = _lstImages;
			totalImages = _lstImages.length;
			imagesLoaded = 0;

			for (var i: uint = 0; i < totalImages; i++) {
				var mc: MovieClip = new MovieClip();
				mc.name = "image" + i;
				mc.visible = false;
				mc.alpha = 0;
				if (linkToVisit != null && linkToVisit != "") {
					mc.buttonMode = true;
				}
				this.addChild(mc);

				var loader: ImageLoader = new ImageLoader();
				loader.tag = i;
				loader.load(_lstImages[i], onImageLoaded);
			}
		}

		function onImageLoaded(_img: MovieClip, _tag: Object):void {
			var sTag: String = _tag.toString();
			var mcOwner: MovieClip = this.getChildByName("image" + sTag) as MovieClip;

			// TODO: Scale the image based on the stage width and height
			Utils.scaleObject(_img, 800, 600);

			if (++imagesLoaded >= totalImages) {
				_bg.removeChild(snakeLoader);
			}

			mcOwner.addChild(_img);
			mcOwner.addEventListener(MouseEvent.CLICK, onClickImage);
			mcOwner.addEventListener(MouseEvent.ROLL_OVER, onOverImage);
			mcOwner.addEventListener(MouseEvent.ROLL_OUT, onOutImage);

			var verSite: VerSite = new VerSite();
			verSite.visible = false;
			verSite.alpha = 0;
			verSite.x = (mcOwner.width / 2) - (verSite.width / 2);
			verSite.y = (mcOwner.height / 2) - (verSite.height / 2) - 30;

			mcOwner.addChild(verSite);

			if (parseInt(sTag) == 0) {
				goNext();
			}
		}

		function onClickImage(e: Event):void {
			if(linkToVisit != null && linkToVisit != "") {
				PageLoader.openWindow(linkToVisit);
			}
		}

		function onOverImage(e: Event):void {
			if (linkToVisit == null ||  linkToVisit == "") return;

			var mcOwner: MovieClip = e.currentTarget as MovieClip;
			var verSite: VerSite = mcOwner.getChildAt(1) as VerSite;
			var yCenter: Number = (mcOwner.height / 2) - (verSite.height / 2);

			TweenLite.to(verSite, 0.3, {
				autoAlpha: 1,
				y: yCenter
			});
		}

		function onOutImage(e: Event):void {
			if (linkToVisit == null || linkToVisit == "") return;

			var mcOwner: MovieClip = e.currentTarget as MovieClip;
			var verSite: VerSite = mcOwner.getChildAt(1) as VerSite;
			var yCenter: Number = (mcOwner.height / 2) - (verSite.height / 2);

			TweenLite.to(verSite, 0.3, {
				autoAlpha: 0,
				y: yCenter - 30
			});
		}

		public function hide():void {
			var thisElem = this,
				theStage = stage;

			TweenLite.to(this, 0.5, {
				alpha: 0,
				onComplete: function() { theStage.removeChild(thisElem); }
			});

			TweenLite.to(mcOverlay, 0.5, {
				autoAlpha: 0,
				delay: 0.5,
				onComplete: function() { theStage.removeChild(mcOverlay); }
			});
		}

		function goNext():void {
			if (currIndex >= totalImages - 1) return;

			var mcOwner: MovieClip = this.getChildByName("image" + currIndex) as MovieClip;

			if(mcOwner != null) {
				TweenLite.to(mcOwner, 0.5, {
					autoAlpha: 0,
					onComplete: function() { navigate(++currIndex); }
				});
			}
			else {
				navigate(++currIndex);
			}
		}

		function goPrev():void {
			if (currIndex <= 0) return;

			var mcOwner: MovieClip = this.getChildByName("image" + currIndex) as MovieClip;

			if(mcOwner != null) {
				TweenLite.to(mcOwner, 0.5, {
					autoAlpha: 0,
					onComplete: function() { navigate(--currIndex); }
				});
			}
			else {
				navigate(--currIndex);
			}
		}

		function navigate(_index: uint):void {
			var mcOwner: MovieClip = this.getChildByName("image" + currIndex) as MovieClip;

			mcOwner.x = borderSize;
			mcOwner.y = borderSize;

			// calculate new background scale values
			var newWidth: Number = mcOwner.width + (2 * borderSize),
				newHeight: Number = mcOwner.height + (2 * borderSize) + lowerPanelSize;

			TweenLite.to(_bg, 0.3, {
				scaleX: newWidth / bgInitialSize,
				scaleY: newHeight / bgInitialSize,
				onUpdate: function() { centerLightbox(null); },
				onComplete: function() {
					TweenLite.to(mcOwner, 0.5, {
						autoAlpha: 1,
						onUpdate: function() {
							mcOwner.x = (_bg.width / 2) - (mcOwner.width / 2);
							mcOwner.y = ((_bg.height - lowerPanelSize) / 2) - (mcOwner.height / 2);
						}
					});
				}
			});

			reorgElements(newWidth, newHeight);

			var imgNumber: uint = currIndex + 1;
			_txtCurrPos.text = imageText + " " +  imgNumber.toString() + " " + ofText + " " + totalImages;
		}

		function reorgElements(
			_nWidth: Number,
			_nHeight: Number):void {

			TweenLite.to(_btnClose, 0.3, {
				x: _nWidth - _btnClose.width - elemsMargin,
				y: _nHeight - _btnClose.height - elemsMargin
			});

			TweenLite.to(_txtCurrPos, 0.3, {
				x: elemsMargin,
				y: _nHeight - _txtCurrPos.height - elemsMargin
			});

			TweenLite.to(_txtClientName, 0.3, {
				x: elemsMargin,
				y: _nHeight - _txtCurrPos.height - elemsMargin - _txtClientName.height
			});

			TweenLite.to(_btnPrev, 0.3, {
				x: - _btnPrev.width - arrowMargin,
				y: (_nHeight / 2) - (_btnPrev.height / 2)
			});

			TweenLite.to(_btnNext, 0.3, {
				x: _nWidth + arrowMargin,
				y: (_nHeight / 2) - (_btnPrev.height / 2)
			});
		}

		function centerLightbox(e: Event):void {
			if (stage == null) return; // This actually happens - scary

			var nStageLeft: int = (Document.StageOrigWidth - stage.stageWidth) / 2,
				nStageTop: int = (Document.StageOrigHeight - stage.stageHeight) / 2;

			this.x = nStageLeft + (stage.stageWidth / 2) - (_bg.width / 2);
			this.y = nStageTop + (stage.stageHeight / 2) - (_bg.height / 2);
		}

		function addTranspOverlay(e: Event):void {
			if (stage == null) return;	// This actually happens - scary

			var nStageLeft = (Document.StageOrigWidth - stage.stageWidth) / 2,
				nStageTop = (Document.StageOrigHeight - stage.stageHeight) / 2,
				g: Graphics = mcOverlay.graphics;

			g.clear();
			g.beginFill(0x000000, 0.78);
			g.drawRect(nStageLeft, nStageTop, stage.stageWidth, stage.stageHeight);
			g.endFill();
		}
	}
}