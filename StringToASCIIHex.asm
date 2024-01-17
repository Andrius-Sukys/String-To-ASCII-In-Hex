; Andrius Šukys
; Programa, kuri atspausdina įvestos simbolių eilutės ASCII kodus šešioliktainiu pavidalu, pvz., įvedus abC1 atspausdina 61 62 43 31

.MODEL Small    ; Nurodoma, kokio dydžio bus programinis kodas              
                    
.STACK 100h     ; Apibrėžiama, kad naudojamas stekas, 100h (256 baitų) dydžio  

.DATA           ; Pažymima, kad nuo čia prasideda duomenų segmentas
	pranesimas1    DB 'Enter a string to convert its symbols to hexadecimal ASCII format:', 10, 13, 36    ; Aprašoma, ką norima dėti į atmintį - apibrėžiamas baito tipo kintamasis pranesimas1  
	pranesimas2    DB 'The Result: ', 10, 13, 36    ; Aprašoma, ką norima dėti į atmintį - apibrėžiamas baito tipo kintamasis pranesimas2 
	pranesimas3    DB 'The input string was empty!', 36   ; Aprašoma, ką norima dėti į atmintį - apibrėžiamas baito tipo kintamasis pranesimas3
	tarpas         DB 32, 36      ; Tarpas (tarpas, dolerio ženklas)
	nauja_eilute   DB 10, 13, 36   ; Nauja eilutė (nauja eilutė, grįžimas į kairę, dolerio ženklas)
	bufferis       DB 255, ?, 255 dup (0)   ; Bufferis, kuris bus reikalingas duomenų nuskaitymui iš vartotojo įvesties (įrašoma 255 (tiek simbolių galima patalpinti bufferyje), su ? paliekama tai, kas tuo metu yra RAMuose, kiti 255 baitai užpildomi nuliais)

.CODE       ; Prasideda kodo segmentas
CodeStart:  ; Žymeklis, kuris pažymi, kad čia prasideda kodas  
	MOV ax, @data    ; Į AX registrą priskiriama duomenų segmento pradžios vieta atmintyje 
	MOV ds, ax       ; Į duomenų segmentą DS perkeliama AX reikšmė, kad DS rodytų į duomenų segmento pradžią
	
	MOV ah, 9h                  ; MS DOS eilutės spausdinimo funkcija: string'as užrašomas standartiniame output'e (ekrane)
	MOV dx, offset pranesimas1  ; Nuoroda į vietą, kur užrašytas pranesimas1, offset - poslinkis nuo duomenų segmento pradžios 
	INT 21h                     ; Pertraukimas: į ekraną išvedamas nurodytas pranešimas 

	MOV ah, 0Ah                 ; MS DOS eilutės nuskaitymo funkcija: vartotojo įvestas string'as įrašomas bufferyje
	MOV dx, offset bufferis     ; Nuoroda į vietą, kur yra rezervuota vieta bufferiui
	INT 21h                     ; Pertraukimas: į bufferį surašoma vartotojo įvestis
    
    MOV ah, 9h                  ; MS DOS eilutės spausdinimo funkcija: string'as užrašomas standartiniame output'e (ekrane)
    MOV dx, offset nauja_eilute ; Nuoroda į vietą, kur užrašyta nauja_eilute 
    INT 21h                     ; Pertraukimas: į ekraną išvedama nauja eilutė
    
	MOV ah, 9h                  ; MS DOS eilutės spausdinimo funkcija: string'as užrašomas standartiniame output'e (ekrane)
	MOV dx, offset pranesimas2  ; Nuoroda į vietą, kur užrašytas pranesimas2
	INT 21h                     ; Pertraukimas: į ekraną išvedamas nurodytas pranešimas
       
	MOV si, offset bufferis     ; Į SI registrą perkeliamas DS segmento poslinkis iki bufferio 
	INC si                      ; Registro SI reikšmė padidinama vienetu
	MOV al, [si]                ; Į AL perkeliama tai, kas yra DS segmente su poslinkiu SI (+ paties bufferio poslinkis 1, todėl tai - skaičius, kiek simbolių buvo nuskaityta)
	
	CMP al, 0   ; AL reikšmė (ivestų narių kiekis) lyginama su nuliu
	JE NoInput  ; Jeigu AL reikšmė lygi nuliui, peršokama į žymę NoInput (vartotojas neįvedė jokių simbolių)
	
	MOV ah, 0   ; AH reikšmei priskiriamas 0  
	MOV cx, 0   ; CX registrui suteikiama reikšmė 0
	MOV cx, ax  ; Į CX registrą įrašoma registro AX reikšmė (CX registre - nuskaitytų simbolių skaičius)
	
Algoritmas:
	MOV ax, 0    ; Registrui AX priskiriama reikšmė 0
	INC si       ; Registro SI reikšmė padidinama vienetu
	MOV al, [si] ; Turinys, saugomas registre SI, persiunčiamas į AL (paties bufferio poslinkis 2 ir daugiau, todėl tai - turinys, saugomas bufferyje)	
	PUSH cx      ; Registro CX reikšmė įdedama į steką
	MOV cx, 0    ; CX registrui priskiriama reikšmė 0
	MOV bx, 16   ; BX registrui priskiriama reikšmė 10, nes verčiant į dešimtainę sistemą bus dalinama iš 10
   
Dalinti:	
    MOV dx, 0    ; DX registrui priskiriama reikšmė 0, nes jo prireiks dalyboje (jame liks skaičiaus liekana po dalybos iš 10)
	DIV bx       ; AX = (DX AX) / BX, DX bus liekana
	PUSH dx      ; Į steką įdedama registro DX reikšmė (dalybos liekana)
	INC cx       ; Registro CX reikšmė padidinama vienetu, nes CX registre rašoma, kiek kartų buvo dalinta (ir kiek liekanų gauta), kiek skaitmenų reikia spausdinti
	CMP ax, 0    ; Tikrinama, ar registras AX (dalybos rezultatas) yra lygus 0 
    JNE Dalinti  ; Jeigu AX registras (dalybos rezultatas) nelygus nuliui, grįžtama į žymę Dalinti

Spausdinti:
	POP dx       ; Iš steko išimama reikšmė ir priskiriama DX registrui 
	ADD dx, 30h  ; Prie registro DX reikšmės pridedama 30h: prie liekanos (kuri gali būti nuo 0 iki 9) pridėjus 30h, gaunama skaitinė reikšmė ASCII kodo pavidalu
	CMP dx, 57   ; DX registro reikšmė lyginama su 57 ('9')
	jbe praleisti; Jeigu reikšmė yra mažesnė nei 9 arba lygi 9, praleidžiame kitą eilutę
	ADD dx, 7    ; Prie DX registro pridedamas skaičius 7
	
Praleisti:
	MOV ah, 2h   ; MS DOS simbolio spausdinimo funkcija: simbolis užrašomas standartiniame output'e (ekrane)
    INT 21h      ; Petraukimas: į ekraną išvedamas simbolis (skaitmuo), kurio reikšmė yra DX registre
    
	DEC cx       ; CX registro reikšmė sumažinama vienetu
	CMP cx, 0    ; Tikrinama, ar CX registras (kuriame nurodoma, kiek skaitmenų reikia spausdinti) lygus nuliui
    JNE Spausdinti  ; Jei CX registras nelygus nuliui (tai yra, išspausdinti ne visi skaitmenys), grįžtama į žymę Spausdinti 

	MOV ah, 9h              ; MS DOS eilutės spausdinimo funkcija: string'as užrašomas standartiniame output'e (ekrane)
	MOV dx, offset tarpas   ; Nuoroda į vietą, kur užrašytas tarpas
	INT 21h                 ; Pertraukimas: į ekraną išvedamas tarpas 
	
	POP cx          ; Iš steko išimama reikšmė, priskiriama registrui CX. Reikšmė rodo, kiek simbolių string'e liko konvertuoti į ASCII kodą šešioliktainiu pavidalu
	DEC cx          ; Registro CX reikšmė sumažinama vienetu
	CMP cx, 0       ; Tikrinama, ar registras CX yra lygus nuliui (ar išspausdinti visų string elementų ASCII kodai šešioliktainiu pavidalu)
    JNE Algoritmas  ; Jeigu registras CX nelygus nuliui, grįžtama į žymę Algoritmas
	
    JMP Finish      ; Peršokama į žymę Finish

NoInput:
	MOV ah, 9h                  ; MS DOS eilutės spausdinimo funkcija: string'as užrašomas standartiniame output'e (ekrane)
	MOV dx, offset pranesimas3  ; Nuoroda į vietą, kur užrašytas pranesimas3 
	INT 21h                     ; Pertraukimas: į ekraną išvedamas nurodytas pranešimas
	                    
Finish:	
	MOV ah, 4Ch ; Programos pabaigos funkcija 
	MOV al, 0	; AL suteikiama reikšmė 0
	INT 21h     ; Baigiamas programos darbas

END CodeStart   ; Programos pabaiga