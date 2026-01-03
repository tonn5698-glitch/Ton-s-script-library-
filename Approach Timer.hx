import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

//Some timer configs! These can be edited
//¡Algunas configuraciones del Tiempo! Estas pueden ser editadas a gusto.
var x: Float = (FlxG.width / 2 - 180 / 2);
//Timer X position 
//Posición X del Tiempo

var y: Float = (FlxG.height / 2 - 18 / 2 + 150);
//Timer Y position
//Posición Y del Tiempo

var barWidth: Int = (180);
//Timer back bar width
//El ancho de la barra trasera del tiempo

var barHeight: Int = (21);
//Timer back bar height
//El alto de la barra trasera del tiempo

var frontBarOffset: Int = (10);
//Front bar space diference
//La diferencia de espacio de la barra del frente

var frontBarToNoteColor: Bool = (true);
//Should the front bar show the next note color?
//¿Debería la barra del frente mostrar el color de la siguiente nota?

var showLastNotes: Bool = (false);
//Should the Timer text also show the last notes?
//¿Debería también el texto del Tiempo mostrar las notas restantes?

var timerSize: Int = (19);
//Timer txt size
//Tamaño del texto del Tiempo

var timerDecimals: Int = (2);
//Timer decimals
//Decimales del Tiempo

var minimumTimer: Float = (null);
//Minimal time to show timer. If the next time is lower than this, the timer will not be shown
//Tiempo mínimo para mostrar el timer. Si el tiempo esta por debajo de este, no se mostrará

var forceOpponentStrum: Bool = (null);
//For Play As Opponent Scripts! Just in case. Can put null or false for don't force it
//¡Para scrips de Play As Opponent (Jugar como el oponente)! Sólo por si acaso. Puedes poner null o false para no forzarlo
//May be useful for UMM too!
//Podría tener un uso para UMM también


//Here the Configs ends, dont pass! You can have errors from here, so, be careful!
//Aquí las configuraciones terminan, ¡No pases! Puedes causar errores si no sabes qué haces
var backBar: FlxSprite;
var frontBar: FlxSprite;
var timerTxt: FlxText;
var timeGroup: Array<FlxSprite, FlxText> = [];
var timerTween: FlxTween;
function onCreatePost(): Void {
 backBar = new FlxSprite().makeGraphic(barWidth, barHeight, FlxColor.BLACK);
 backBar.cameras = [camOther];
 backBar.setPosition(x, y);
 add(backBar);
 backBar.alpha = 0.0001; //Cosa del precache. Antes no era necesaria, pero supongo que por la variable de Tiempo mínimo ahora lo es

 frontBar = new FlxSprite().makeGraphic(backBar.width - frontBarOffset, backBar.height - frontBarOffset, FlxColor.WHITE);
 frontBar.cameras = backBar.cameras;
 add(frontBar);

 timerTxt = new FlxText(0, 0, 0, '');
 timerTxt.setFormat(Paths.font('vcr.ttf'), timerSize, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
 timerTxt.scrollFactor.set();
 timerTxt.borderSize = 1.25;
 add(timerTxt);
 timerTxt.cameras = [camOther];
};
var finished: Bool = false;
var curTime: Float = null;
var lastTime: Float = null;
var lastPosition: Float = null;
var waitUntil: Float = null;
var curColor: Int = null;
var notesRemaining: Int = null;
function onUpdate(): Void {
 if (curTime != null) doTimerUpdate(curTime / 1000 - Conductor.songPosition / 1000);
 else doNextTimerCheck();
 if (curTime != null && timerTween != null) {
  timerTween.cancel();
  timerTween = null;
 };
 doTimerObjectsUpdate();
};
var startedTime: Float = null;
function doTimerUpdate(time: Float = null): Void {
 if (lastPosition == null) lastPosition = Conductor.songPosition;
 if (startedTime == null) startedTime = time;
 var canBeShowedByTime: Bool = (minimumTimer == null || minimumTimer != null && startedTime >= minimumTimer);
 if (time != null && canBeShowedByTime) {
  if (backBar.alpha != 1) backBar.alpha = 1;
  frontBar.scale.x = Math.min(1, Math.max(0, time / (curTime / 1000 - lastPosition / 1000)));
  if (curColor != null && frontBarToNoteColor) frontBar.color = curColor;
  if (time < 0) time = 0;
  if (timerTxt != null) timerTxt.text = floorDecimal(time, timerDecimals) + (showLastNotes ? (' (' + notesRemaining + ')') : '');
 };
 if (Conductor.songPosition >= curTime) doTimerFinishFunction();
 else if (lastTime != null && Conductor.songPosition < lastTime) doBackInSongFunction();
};
function doTimerFinishFunction(): Void {
 lastTime = curTime;
 curTime = lastPosition = null;
 startedTime = null;
 timerTween = FlxTween.tween(backBar, {alpha: 0.0001}, 0.25 / game.playbackRate, {
  onComplete: function(twn: FlxTween) {
   timerTween = null;
   curColor = null;
  }
 });
};
function doBackInSongFunction(): Void {
 lastTime = curTime = lastPosition = null;
 startedTime = null;
 backBar.alpha = 0.0001;
};
function doNextTimerCheck(): Void {
 var type: Bool = PlayState.instance.opponentMode != null ? PlayState.instance.opponentMode : (forceOpponentStrum != null ? !forceOpponentStrum : true);
 if (waitUntil != null) {
  if (Conductor.songPosition >= waitUntil) waitUntil = null;
 } else curTime = getNextTime(type);
};
function doTimerObjectsUpdate(): Void {
 frontBar.x = backBar.x + backBar.width / 2 - frontBar.width / 2;
 frontBar.y = backBar.y + backBar.height / 2 - frontBar.height / 2;
 timerTxt.x = frontBar.x + frontBar.width / 2 - timerTxt.width / 2;
 timerTxt.y = frontBar.y + frontBar.height / 2 - timerTxt.height / 2;
 timerTxt.alpha = frontBar.alpha = backBar.alpha;
};
function floorDecimal(value: Float, decimals: Int = 0): Float {
 if (value == null) return;
 if (decimals <= 0 || decimals == null) return Math.floor(value);
 var factor = Math.pow(10, decimals);
 var flooredValue = Math.floor(value * factor) / factor;
 return formatDecimals(flooredValue, decimals);
};
function formatDecimals(value: Float, decimals: Int): String {
 var parts = Std.string(value).split(".");
 var integerPart = parts[0];
 var decimalPart = parts.length > 1 ? parts[1] : "0";
 while (decimalPart.length < decimals) decimalPart += "0";
 if (decimalPart.length > decimals) decimalPart = decimalPart.substr(0, decimals);
 return integerPart + "." + decimalPart;
};
function getNextTime(playerStrums: Bool = true): Float {
 var leTime: Float = null;
 var mustPressExists: Bool = false;
 var foundInside: Bool = false;
 var strum: FlxTypedGroup = playerStrums ? game.playerStrums : game.opponentStrums;
 if (notes.length > 0 && lastTime != null) {
  for (n in notes) {
   if (n.mustPress == playerStrums && !n.hitCausesMiss) {
    if ((strum.members[n.noteData].downScroll ? n.y >= 0 : n.y < FlxG.height && camHUD.alpha >= 0.4)) {
     mustPressExists = true;
     foundInside = true;
     waitUntil = n.strumTime;
     break;
    };
   };
  };
  for (n in notes) {
   if (foundInside) break;
   if (n.mustPress == playerStrums && !n.hitCausesMiss) {
    if ((strum.members[n.noteData].downScroll ? n.y < 0 : n.y >= FlxG.height)) {
     mustPressExists = true;
     leTime = n.strumTime;
     if (frontBarToNoteColor) curColor = n.rgbShader.r;
    };
   };
  };
 };
 if (!mustPressExists && unspawnNotes.length > 0) {
  for (n in unspawnNotes) {
   if (n.mustPress == playerStrums && !n.hitCausesMiss) {
    mustPressExists = true;
    leTime = n.strumTime;
    if (frontBarToNoteColor) curColor = n.rgbShader.r;
    break;
   };
  };
 };
 finished = !mustPressExists;
 if (leTime != null && showLastNotes) {
  var leCount: Int = 0;
  if (notes.length > 0) {
   for (n in notes) {
    if (n.mustPress == playerStrums && !n.hitCausesMiss && !n.isSustainNote) leCount++;
   };
  };
  if (unspawnNotes.length > 0) { 
   for (n in unspawnNotes) {
    if (n.mustPress == playerStrums && !n.hitCausesMiss && !n.isSustainNote) leCount++;
   };
  };
  notesRemaining = leCount;
 };
 return leTime;
};