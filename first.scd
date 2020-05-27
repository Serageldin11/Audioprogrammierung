//Serageldin El-Khodary
//849727

MIDIClient.init;
MIDIIn.connectAll;

(
~noten = Array.newClear(128); //array für noten
~amp = 0.05;
~bend = 63; //pitch bender
~envAtc = 0.01; //attackTime fuer Envelope
~envDct = 0.3; //decayTime fuer Envelope
~envRlt = 1.0; //decayTime fuer Envelope
~lpff = 2000; //LPF frequenz
~hpff = 20; //HPF frequenz
~bpfon = 0; //um BPF an oder abzuschalten
~bpff = 440; //BPF frequenz
~chanCheck = 0; //channelchecker Midi if abfragen
~chanVal = 0; //channel value knobs
~curv = 0;
~oct = 1;
)

//gui
(
Window.closeAll;
w = Window.new("Gui", Rect.new(1000, 540, 450, 100))
.front
.alwaysOnTop = true;

//Attack
~atcg = NumberBox(w,Rect(5,10,100,20))
.value_(~envAtc.linlin(0,127,0,1))
.align_(\center);
~freqLabel = StaticText(w, Rect(5,30,100,10))
.string_("Attack (sek)")
.align_(\center)
.background = Color.green;

//Decay
~dctg = NumberBox(w,Rect(115 ,10,100,20))
.value_(~envDct.linlin(0,127,0,1))
.align_(\center);
~freqLabel = StaticText(w, Rect(115,30,100,10))
.string_("Decay")
.align_(\center)
.background = Color.green;

//Release
~rltg = NumberBox(w,Rect(225,10,100,20))
.value_(~envRlt.linlin(0,127,0,1) )
.align_(\center);
~freqLabel = StaticText(w, Rect(225,30,100,10))
.string_("Release (sek)")
.align_(\center)
.background = Color.green;

//LPF
~lpfg = NumberBox(w,Rect(5,60,100,20))
.value_(~lpff.linlin(0,127,20,2000))
.align_(\center);
~freqLabel = StaticText(w, Rect(5,80,100,10))
.string_("LPF (Hz)")
.align_(\center)
.background = Color.green;

//HPF
~hpfg = NumberBox(w,Rect(115,60,100,20))
.value_(~hpff.linlin(0,127,20,2000))
.align_(\center);
~freqLabel = StaticText(w, Rect(115,80,100,10))
.string_("HPF (Hz)")
.align_(\center)
.background = Color.green;

//BPF
~bpfg = NumberBox(w,Rect(225,60,100,20))
.value_(~bpff.linlin(0,127,20,2000))
.align_(\center);
~freqLabel = StaticText(w, Rect(225,80,100,10))
.string_("BPF (Hz)")
.align_(\center)
.background = Color.green;

//Wave auswählen
~wave = Button(w, Rect(335, 15, 100, 20))
.states_([
	["Sinus"],
	["Pulse"],
	["Sawtooth"]
])
.action_({

	switch (~wave.value, //switch um kurve festzulegen;
		0,{ ~curv = 0; },
		1,{ ~curv = 1; },
		2,{ ~curv = 2; }
);
});

//Octave
~octa = NumberBox(w,Rect(335,60,60,20))
.value_(1)
.align_(\center)
.action_({~knob.value_(~octa.value); ~oct=~octa.value}.defer(0));
~freqLabel = StaticText(w, Rect(335,80,60,10))
.string_("Octave")
.align_(\center)
.background = Color.green;
~knob = Knob(w, Rect(405, 60, 30, 30))
.centered_(true)
.keystep_(0.1)
.action_({~octa.value_(~knob.value.linlin(0,1,0,10));~oct=~knob.value.linlin(0,1,0,10)}.defer(0););

)




/*r={( //Reglerwerte für die gui aktualisieren
Routine{1.do{
~hpfg.value_(~hpff.linlin(0,127,20,2000));
};}.play(AppClock)
)};
*/

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	var midcps = nn.midicps*~oct; //Octave waehlen. 1 => C = 440Hz
	//[vel, nn ].postln;

	switch (~curv, //switch um kurve festzulegen;
		0,{ 	~noten[nn] = Synth.new(
		\synthSin,
		[
			\freq, midcps,//.postln,// Midi zu Hz umgerechnet
			\amp, ~amp.linexp(0,127,0.05,1),
			\gate, 1,
			\bend, ~bend.linlin(0,127,-2,2), //2 = ganze stufe hoch oder runter
			\lpfv, ~lpff.linlin(0,127,20,2000),
			\hpfv, ~hpff.linlin(0,127,20,2000),
			\bpfon, 1,
			\bpfv, ~bpff.linlin(0,127,20,2000),
			\atc, ~envAtc.linlin(0,127,0,1),
			\dct, ~envDct.linlin(0,127,0,1),
			\rlt, ~envRlt.linlin(0,127,0,1),
		]
	);
		},
		1,{ ~noten[nn] = Synth.new(
		\synthPulse,
		[
			\freq, midcps,//.postln,// Midi zu Hz umgerechnet
			\amp, ~amp.linexp(0,127,0.05,1),
			\gate, 1,
			\bend, ~bend.linlin(0,127,-2,2), //2 = ganze stufe hoch oder runter
			\lpfv, ~lpff.linlin(0,127,20,2000),
			\hpfv, ~hpff.linlin(0,127,20,2000),
			\bpfon, 1,
			\bpfv, ~bpff.linlin(0,127,20,2000),
			\atc, ~envAtc.linlin(0,127,0,1),
			\dct, ~envDct.linlin(0,127,0,1),
			\rlt, ~envRlt.linlin(0,127,0,1),
		]
	); },
		2,{ ~noten[nn] = Synth.new(
		\synthSaw,
		[
			\freq, midcps,//.postln,// Midi zu Hz umgerechnet
			\amp, ~amp.linexp(0,127,0.05,1),
			\gate, 1,
			\bend, ~bend.linlin(0,127,-2,2), //2 = ganze stufe hoch oder runter
			\lpfv, ~lpff.linlin(0,127,20,2000),
			\hpfv, ~hpff.linlin(0,127,20,2000),
			\bpfon, 1,
			\bpfv, ~bpff.linlin(0,127,20,2000),
			\atc, ~envAtc.linlin(0,127,0,1),
			\dct, ~envDct.linlin(0,127,0,1),
			\rlt, ~envRlt.linlin(0,127,0,1),
		]
	); }
);


});


MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	//[vel, nn].postln;
	~noten[nn].set(\gate, 0);
	~noten[nn] = nil;
});


MIDIdef.cc(\bendTest, { //Regler durch knopf ersetzt
	arg val, chan, src;
	//[val, chan, src].postln;
	~chanCheck = chan;
	~chanVal = val;
//r.value;
	//knob 51 Amp
	if (~chanCheck == 51, {~amp = val;}); //globale bend variable nur beim richtigen knob ändern.
	if (~chanCheck == 51, {~noten.do{arg synth; synth.set(\amp, ~chanVal.linexp(0,127,0.05,1))};}); //knob 51 fuer amp

	//knob 52 pitchbend
	if (~chanCheck == 52, {~bend = val;});
	if (~chanCheck == 52, {~noten.do{arg synth; synth.set(\bend, ~chanVal.linlin(0,127,-2,2))};});

	//knob 48 env attackTime
	if (~chanCheck == 48, {~envAtc = val; {~atcg.value_(~envAtc.linlin(0,127,0,1))}.defer(0);});


	//knob 49 env decayTime
	if (~chanCheck == 49, {~envDct = val; {~dctg.value_(~envDct.linlin(0,127,0,1))}.defer(0);});


	//knob 50 env releaseTime
	if (~chanCheck == 50, {~envRlt = val; {~rltg.value_(~envRlt.linlin(0,127,0,1))}.defer(0);});


	//knob 53 LPF cutoff freq
	if (~chanCheck == 53, {~lpff = val; {~lpfg.value_(~lpff.linlin(0,127,20,2000))}.defer(0);});


	//knob 54 HPF cutoff freq
	if (~chanCheck == 54, {~hpff = val; {~hpfg.value_(~hpff.linlin(0,127,20,2000))}.defer(0);});


	//knob 55 BPF cutoff freq
	if (~chanCheck == 55, {~bpff = val; {~bpfg.value_(~bpff.linlin(0,127,20,2000))}.defer(0);});

});
)



(
SynthDef.new(\synthSin, {
	arg freq = 440, amp = 0.05, gate = 0, bend = 0,
	lpfv = 2000, //LPF freq
	hpfv = 20, //HPF freq
	bpfv = 440, //BPF freq
	bprrq = 1.0, //Breite der vom BPF durchgelassenen frequenzen
	atc = 0.1, //env attackTime
	dct = 0.3, //env decayTime;
	rlt = 1.0; //releaseTime
	var sig, env, envAdsr, lpf, hpf;


	sig = SinOsc.ar(freq * bend.midiratio)!2;
	//sig = LFPulse.ar(freq * bend.midiratio)!2;
	//sig = LFSaw.ar(freq * bend.midiratio)!2;

	envAdsr = Env.adsr(atc, dct, 0.5, rlt, 1.0,0.0);
	env = EnvGen.kr(envAdsr, gate, doneAction:2);
	sig = sig * env * amp;
	sig = LPF.ar(sig, lpfv);
	sig = HPF.ar(sig, hpfv);
	//sig = BPF.ar(sig, bpfv, 1.0);
	//sig = sig * SinOsc.ar(MouseX.kr(1,10, 1)); //LFO mit Maussteuerung
	Out.ar(0, sig);
}).add;
)

(
SynthDef.new(\synthPulse, {
	arg freq = 440, amp = 0.05, gate = 0, bend = 0,
	lpfv = 2000, //LPF freq
	hpfv = 20, //HPF freq
	bpfv = 440, //BPF freq
	bprrq = 1.0, //Breite der vom BPF durchgelassenen frequenzen
	atc = 0.1, //env attackTime
	dct = 0.3, //env decayTime;
	rlt = 1.0; //releaseTime
	var sig, env, envAdsr, lpf, hpf;


	//sig = SinOsc.ar(freq * bend.midiratio)!2;
	sig = LFPulse.ar(freq * bend.midiratio)!2;
	//sig = LFSaw.ar(freq * bend.midiratio)!2;

	envAdsr = Env.adsr(atc, dct, 0.5, rlt, 1.0,0.0);
	env = EnvGen.kr(envAdsr, gate, doneAction:2);
	sig = sig * env * amp;
	sig = LPF.ar(sig, lpfv);
	sig = HPF.ar(sig, hpfv);
	//sig = BPF.ar(sig, bpfv, 1.0);
	//sig = sig * SinOsc.ar(MouseX.kr(1,10, 1)); //LFO mit Maussteuerung
	Out.ar(0, sig);
}).add;
)

(
SynthDef.new(\synthSaw, {
	arg freq = 440, amp = 0.05, gate = 0, bend = 0,
	lpfv = 2000, //LPF freq
	hpfv = 20, //HPF freq
	bpfv = 440, //BPF freq
	bprrq = 1.0, //Breite der vom BPF durchgelassenen frequenzen
	atc = 0.1, //env attackTime
	dct = 0.3, //env decayTime;
	rlt = 1.0; //releaseTime
	var sig, env, envAdsr, lpf, hpf;


	//sig = SinOsc.ar(freq * bend.midiratio)!2;
	//sig = LFPulse.ar(freq * bend.midiratio)!2;
	sig = LFSaw.ar(freq * bend.midiratio)!2;

	envAdsr = Env.adsr(atc, dct, 0.5, rlt, 1.0,0.0);
	env = EnvGen.kr(envAdsr, gate, doneAction:2);
	sig = sig * env * amp;
	sig = LPF.ar(sig, lpfv);
	sig = HPF.ar(sig, hpfv);
	//sig = BPF.ar(sig, bpfv, 1.0);
	//sig = sig * SinOsc.ar(MouseX.kr(1,10, 1)); //LFO mit Maussteuerung
	Out.ar(0, sig);
}).add;
)






//if (x == y, {"x und y sind gleich".postln;});


