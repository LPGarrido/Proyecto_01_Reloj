PROCESSOR 16F887

; PIC16F887 Configuration Bit Settings
; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

; -------------- MACROS ---------------
  ; Macro para reiniciar el valor del TMR0
  RESET_TMR0 MACRO TMR_VAR
    BANKSEL TMR0	    ; cambiamos de banco
    MOVLW   TMR_VAR
    MOVWF   TMR0	    ; configuramos tiempo de retardo
    BCF	    T0IF	    ; limpiamos bandera de interrupción
    ENDM

; Macro para reiniciar el valor del TMR1
; Recibe el valor a configurar en TMR1_H y TMR1_L
RESET_TMR1 MACRO TMR1_H, TMR1_L	 ;
    BANKSEL TMR1H
    MOVLW   TMR1_H	    ; Literal a guardar en TMR1H
    MOVWF   TMR1H	    ; Guardamos literal en TMR1H
    MOVLW   TMR1_L	    ; Literal a guardar en TMR1L
    MOVWF   TMR1L	    ; Guardamos literal en TMR1L
    BCF	    TMR1IF	    ; Limpiamos bandera de int. TMR1
    ENDM

; ------- VARIABLES EN MEMORIA --------
PSECT udata_shr		    ; Memoria compartida
    W_TEMP:		DS 1
    STATUS_TEMP:	DS 1

PSECT udata_bank0	    ; Variables a utilizar
    ;Variables tiempo real
    SEGUNDOS:		DS 1
    MINUTOS:		DS 1
    HORAS:		DS 1
    UNIDADES_SEG:	DS 1	
    DECENAS_SEG:	DS 1	
    UNIDADES_MIN:	DS 1	
    DECENAS_MIN:	DS 1	
    UNIDADES_HORA:	DS 1	
    DECENAS_HORA:	DS 1	
    ;Variables para la configuración tiempo real
    MINUTOS_C:		DS 1
    HORAS_C:		DS 1
    UNIDADES_MIN_C:	DS 1	
    DECENAS_MIN_C:	DS 1	
    UNIDADES_HORA_C:	DS 1	
    DECENAS_HORA_C:	DS 1	
    ;Variables fecha
    DIA:		DS 1
    MES:		DS 1
    UNIDADES_MES:	DS 1	
    DECENAS_MES:	DS 1	
    UNIDADES_DIA:	DS 1	
    DECENAS_DIA:	DS 1	
    ;Variables fecha configuracion
    DIA_C:		DS 1
    MES_C:		DS 1
    UNIDADES_MES_C:	DS 1	
    DECENAS_MES_C:	DS 1	
    UNIDADES_DIA_C:	DS 1	
    DECENAS_DIA_C:	DS 1	
    ; Variable tiempo timer
    SEG_TMR:		DS 1
    MINUTOS_TMR:	DS 1
    UNIDADES_MIN_TMR:	DS 1	
    DECENAS_MIN_TMR:	DS 1	
    UNIDADES_SEG_TMR:	DS 1	
    DECENAS_SEG_TMR:	DS 1	
    ; Variable tiempo timer configuracion
    SEG_TMR_C:		DS 1
    MINUTOS_TMR_C:	DS 1
    UNIDADES_MIN_TMR_C:	DS 1	
    DECENAS_MIN_TMR_C:	DS 1	
    UNIDADES_SEG_TMR_C: DS 1	
    DECENAS_SEG_TMR_C:	DS 1	
    ;Variable tiempo alarma
    MINUTOS_ALARMA:	    DS 1
    HORAS_ALARMA:	    DS 1
    UNIDADES_MIN_ALARMA:    DS 1
    DECENAS_MIN_ALARMA:	    DS 1
    UNIDADES_HORA_ALARMA:   DS 1
    DECENAS_HORA_ALARMA:    DS 1
    ;Variable tiempo alarma configuracion
    MINUTOS_ALARMA_C:	    DS 1
    HORAS_ALARMA_C:	    DS 1
    UNIDADES_MIN_ALARMA_C:  DS 1	
    DECENAS_MIN_ALARMA_C:   DS 1	
    UNIDADES_HORA_ALARMA_C: DS 1	
    DECENAS_HORA_ALARMA_C:  DS 1
    
    BANDERAS:		DS 1	; Indica que display hay que encender
    DISPLAY:		DS 4	; Representación de cada nibble en el display de 7-seg
    TEMP:		DS 1	; Variable temporal
    ESTADOS:		DS 1	; Variable Estados
    CUENTA_SEG:		DS 1	; Cuenta segundos
    CUENTA_100ms:	DS 1	; Cuenta cada 100 ms
    CUENTA_500ms:	DS 1	; Cuenta cada 500 ms
    tCUENTA_100ms:	DS 1	; temporal cuenta cada 100 ms

PSECT resVect, class=CODE, abs, delta=2
ORG 00h			    ; posición 0000h para el reset
;------------ VECTOR RESET --------------
resetVec:
    PAGESEL MAIN	; Cambio de pagina
    GOTO    MAIN

PSECT intVect, class=CODE, abs, delta=2
ORG 04h			    ; posición 0004h para interrupciones
;------- VECTOR INTERRUPCIONES ----------
PUSH:
    MOVWF   W_TEMP	    ; Guardamos W
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP	    ; Guardamos STATUS

ISR:
    BTFSC   T0IF	    ; Interrupcion de TMR0
    CALL    INT_TMR0	    ; Subrutina de interrupción
    BTFSC   TMR1IF	    ; Interrupcion de TMR1
    CALL    INT_TMR1	    ; Subrutina de interrupción
    BTFSC   TMR2IF	    ; Interrupcion de TMR2
    CALL    INT_TMR2	    ; Subrutina de interrupción
    BTFSC   RBIF	    ; Interrupcion de IOCB
    CALL    INT_PORTB	    ; Subrutina de interrupción

POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS	    ; Recuperamos el valor de reg STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W	    ; Recuperamos valor de W
    RETFIE		    ; Regresamos a ciclo principal

; ------ SUBRUTINAS DE INTERRUPCIONES ------
INT_TMR0:
    RESET_TMR0 252	    ; Reiniciamos TMR0 para 2ms
    CALL MOSTRAR_VALORES    ; Mostrar valores en el display
    RETURN

INT_TMR1:
    RESET_TMR1 0xC2, 0xF7   ; Reiniciamos TMR1 para 1000ms
    CALL FUNCION_TIEMPO	    ; Funcion tiempo
    BTFSC   RA6		    ; Si RA6=1 (Timer activado) = Funcion TMR, RA6=0 Saltar
    CALL    FUNCION_TMR	    ; Funcion TMR
    BTFSS   RE0		    ; Si la alarma esta encendida ir a su funcion
    RETURN		    ; Alarma apagada, regresar
    INCF    CUENTA_SEG	    ; Aumenta la cuenta de segundos
    MOVF    CUENTA_SEG,W    
    SUBLW   60		    ; Cuenta hasta 60 segundos
    BTFSS   STATUS,2
    RETURN		    ; Regresa si no son 60 segundos
    BCF	    RE0		    ; Cuando sean 60, apagar RE0
    RETURN		    ; Regresa

INT_TMR2:
    BCF	    TMR2IF	    ; Limpiamos bandera de interrupcion de TMR1
    INCF    CUENTA_100ms    ; Aumenta la cuenta de 100 ms
    INCF    tCUENTA_100ms   ; Aumenta la cuenta temporal de 100 ms
    
    MOVF    tCUENTA_100ms,W
    XORLW   5		    ; Cuenta 5 veces 100 ms
    BTFSS   STATUS,2
    GOTO    $+3
    INCF    CUENTA_500ms    ; Aumentar la cuenta de 500ms
    CLRF    tCUENTA_100ms   ; Limpia el temporal de 100 ms
    
    BTFSS   RA7		    ; Si el modo alarma esta activado, haga la funcion
    RETURN		    ; regres
    MOVF    MINUTOS_ALARMA,W	
    XORWF   MINUTOS,W	    ; Compara los minutos
    BTFSS   STATUS,2
    RETURN		    ; Si los minutos no son iguales, regresa
    MOVF    HORAS_ALARMA,W  ; Si son iguales, compara las horas
    XORWF   HORAS,W
    BTFSS   STATUS,2
    RETURN		    ; Si las horas no son iguales, regresa
    BSF	    RE0		    ; Si son iguales enciende la alarma
    RETURN		    ; Regresa

INT_PORTB:
    BTFSS   PORTB,0		; RB0=0 Cambio modo, RB0=1 evaluar
    CALL    INT_RB0
    BTFSS   PORTB,1		; RB1=0 Modo config, RB1=1 evaluar
    CALL    INT_RB1
    BTFSS   PORTB,2		; RB1=0 Aumentar, RB1=1 evaluar
    CALL    INT_RB2
    BTFSS   PORTB,3		; RB1=0 Disminuir, RB1=1 evaluar
    CALL    INT_RB3
    BTFSS   PORTB,4		; RB1=0 cambios variable, RB1=1 evaluar
    CALL    INT_RB4
    BCF	    RBIF		; limpiar bandera
    RETURN

;----------

FUNCION_TIEMPO:
    INCF    SEGUNDOS		; Aumentar segundos
    MOVF    SEGUNDOS,W
    XORLW   60			; Comparar que sea igual a 60
    BTFSS   STATUS,2		
    RETURN			; Regresa si no es igual
    INCF    MINUTOS		; Incrementar minutos si es = 60
    CLRF    SEGUNDOS		; Limpiar los segundos
    MOVF    MINUTOS,W		
    XORLW   60			; Comparar que los minutos sean igual a 60
    BTFSS   STATUS,2
    RETURN			; Regresa si no es = 60
    INCF    HORAS		; Si es 60, incrementar horas
    CLRF    MINUTOS		; Limpiar minutos
    MOVF    HORAS,W
    XORLW   24			; Comparar que las horas sean igual a 24
    BTFSS   STATUS,2
    RETURN			; Si no es igual regresa
    CLRF    HORAS		; Si es igual limpia horas
    INCF    DIA			; Aumenta dias
    ; Por cada mes, compara el num del mes y si es igual checkea la cantidad max de dias
    ; ENERO
    MOVF    MES,W
    XORLW   1
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN
    ; FEBRERO
    MOVF    MES,W
    XORLW   2
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_28
    RETURN
    ; MARZO
    MOVF    MES,W
    XORLW   3
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN
    ; ABRIL
    MOVF    MES,W
    XORLW   4
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_30
    RETURN
    ; MAYO
    MOVF    MES,W
    XORLW   5
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN
    ; JUNIO
    MOVF    MES,W
    XORLW   6
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_30
    RETURN
    ; JULIO
    MOVF    MES,W
    XORLW   7
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN
    ; AGOSTO
    MOVF    MES,W
    XORLW   8
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN
    ; SEPTIEMBRE
    MOVF    MES,W
    XORLW   9
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_30
    RETURN
    ; OCTUBRE
    MOVF    MES,W
    XORLW   10
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN
    ; NOVIEMBRE
    MOVF    MES,W
    XORLW   11
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_30
    RETURN
    ; DICIEMBRE
    MOVF    MES,W
    XORLW   12
    BTFSS   STATUS,2
    GOTO    $+3
    CALL    CHECK_MES_31
    RETURN  

CHECK_MES_31:
    MOVF    DIA,W
    SUBLW   31
    BTFSC   STATUS,0	;C=0 DIA>31 funcion;  C=1 DIA=<31 regresa
    RETURN		
    MOVLW   1		;Colocar dias en 1
    MOVWF   DIA
    INCF    MES		;Incrementar meses
    MOVF    MES,W	
    XORLW   13		; Comparar que el mes sea igual a 13
    BTFSS   STATUS,2
    RETURN		; Si no es igual regresa
    MOVLW   1
    MOVWF   MES		; Si es igual colocar mes en 1
    RETURN
; Igual que la funcion anterior solo que compara la cantidad de dias sea 30
; No evalua la cantidad de meses porque el cambio de mes solo es en dic (31 dias)
CHECK_MES_30:
    MOVF    DIA,W
    SUBLW   30
    BTFSC   STATUS,0	;C=0 DIA>30;  C=1 DIA?30
    RETURN
    MOVLW   1
    MOVWF   DIA
    INCF    MES
    RETURN
; Igual que la funcion anterior solo que compara la cantidad de dias sea 28
; No evalua la cantidad de meses porque el cambio de mes solo es en dic (31 dias) 
CHECK_MES_28:
    MOVF    DIA,W
    SUBLW   28
    BTFSC   STATUS,0	;C=0 DIA>28;  C=1 DIA?28
    RETURN
    MOVLW   1
    MOVWF   DIA
    INCF    MES
    RETURN
    
FUNCION_TMR:
    DECF    SEG_TMR	    ;Decrementa los segundos TMR
    BTFSS   SEG_TMR,7	    ;Compara si la cuenta es negativa
    RETURN		    ; Si no lo es regresa
    MOVLW   59		    
    MOVWF   SEG_TMR	    ; Si es negativo, regresa a 59 los segundos
    DECF    MINUTOS_TMR	    ; Decrementa los minutos
    BTFSS   MINUTOS_TMR,7   ;Compara que los minutos no sean negativos
    RETURN		    ; SI no es negativo regresa
    BCF	    RA6		    ; Si es negativo (el tiempo se acabo) Apaga el modo timer
    BSF	    RE0		    ; Enciende la alarma
    CLRF    SEG_TMR	    ; Coloca en 0 los segundos y minutos
    CLRF    MINUTOS_TMR
    RETURN
    
;------------
 INT_RB0:
    BTFSC   RA4		    ; Si estamos en modo de config, regresar. Si no ejecuta la funcion
    RETURN
    INCF    ESTADOS	    ;Incrementar estados
    MOVF    ESTADOS,W	    
    ANDLW   0x03	    ; Solo nos intera los 2 bits menos significativos
    MOVWF   ESTADOS
 RETURN

INT_RB1:
    BTFSC   RA0			; RA0 = 1 Funcion, RA0 = 0 evaluar
    GOTO    CONFIG_ESTADO_0	; RELOJ
    BTFSC   RA1			; RA1 = 1 Funcion, RA1 = 0 evaluar
    GOTO    CONFIG_ESTADO_1	; FECHA
    BTFSC   RA2			; RA2 = 1 Funcion, RA2 = 0 evaluar
    GOTO    CONFIG_ESTADO_2	; TIMER
    BTFSC   RA3			; RA3 = 1 Funcion, RA3 = 0 evaluar
    GOTO    CONFIG_ESTADO_3	; ALARMA

    CONFIG_ESTADO_0:		; RELOJ
	BTFSC	RA4		; Si RA4=0 - Encender RA4; Si RA4=1 Apagar RA4 y Cambio
	GOTO	$+3
	BSF	RA4
	RETURN
	BCF	RA4
	; Cambio de las variables de configuracion a las reales
	CLRF	SEGUNDOS
	MOVF	MINUTOS_C,W
	MOVWF	MINUTOS
	MOVF	HORAS_C,W
	MOVWF	HORAS
    RETURN

    CONFIG_ESTADO_1:	    ; FECHA
	BTFSC	RA4	    ; Si RA4=0 - Encender RA4; Si RA4=1 Apagar RA4 y Cambio
	GOTO	$+3
	BSF	RA4
	RETURN
	BCF	RA4
	; Cambio de las variables de configuracion a las reales
	MOVF	MES_C,W
	MOVWF	MES
	MOVF	DIA_C,W
	MOVWF	DIA
    RETURN

    CONFIG_ESTADO_2:	    ; TMR
	BTFSC	RA4	    ; Si RA4=0 - Encender RA4; Si RA4=1 Apagar RA4 y Cambio
	GOTO	$+4
	BSF	RA4
	BCF	RA6
	RETURN
	BCF	RA4
	; Cambio de las variables de configuracion a las reales
	BSF	RA6	    ; Encender modo TMR
	MOVF	SEG_TMR_C,W
	MOVWF	SEG_TMR
	MOVF	MINUTOS_TMR_C,W
	MOVWF	MINUTOS_TMR
    RETURN

    CONFIG_ESTADO_3:	    ; ALARMA
	BTFSC	RA4	    ; Si RA4=0 - Encender RA4; Si RA4=1 Apagar RA4 y Cambio
	GOTO	$+4
	BSF	RA4
	BCF	RA7
	RETURN
	BCF	RA4
	; Cambio de las variables de configuracion a las reales
	BSF	RA7	    ; Encender modo ALARMA
	MOVF	MINUTOS_ALARMA_C,W
	MOVWF	MINUTOS_ALARMA
	MOVF	HORAS_ALARMA_C,W
	MOVWF	HORAS_ALARMA
    RETURN

INT_RB2:
    BTFSC   RE0		    ; Si ALARMA=1 Apagarla, ALARMA=0 evaluar
    BCF	    RE0
    BTFSS   RA4		    ; Si esta en modo config seguir, sino regresar
    RETURN
    ;Verificar en qué modo estamos
    BTFSC   RA0			
    GOTO    INC_ESTADO_0	; RELOJ
    BTFSC   RA1
    GOTO    INC_ESTADO_1	; FECHA
    BTFSC   RA2
    GOTO    INC_ESTADO_2	; TIMER
    BTFSC   RA3
    GOTO    INC_ESTADO_3	; ALARMA

    INC_ESTADO_0:
	BTFSS	RA5		    ; Dependiendo de la variable
	GOTO	INC_MINUTOS_RELOJ
	GOTO	INC_HORAS_RELOJ
	INC_MINUTOS_RELOJ:
	INCF	MINUTOS_C	    ; Aumenta minutos
	MOVF	MINUTOS_C,W
	XORLW	60		    ; min=60 limpia los minutos, min no= 60 regresa 
	BTFSS	STATUS,2
	RETURN			    
	CLRF	MINUTOS_C
	RETURN
	INC_HORAS_RELOJ:
	INCF	HORAS_C		    ; Aumenta horas
	MOVF	HORAS_C,W
	XORLW	24		    ; horas=24 limpia horas, horas no=24 regresa
	BTFSS	STATUS,2
	RETURN
	CLRF	HORAS_C
	RETURN

    INC_ESTADO_1:   
	BTFSS	RA5		    ; Dependiendo de la variable
	GOTO	INC_MES_RELOJ
	GOTO	INC_DIA_RELOJ
	INC_MES_RELOJ:
	INCF	MES_C		    ; Aumenta mes
	MOVF	MES_C,W
	XORLW	13		    ; mes=13 - mes=1, mes no=13 regresa
	BTFSS	STATUS,2
	RETURN
	MOVLW	1
	MOVWF	MES_C
	RETURN
	INC_DIA_RELOJ:
	INCF	DIA_C		    ; Aumenta dia
	; Dependiendo del mes compara la cantidad maxima
	MOVF	MES_C,W
	XORLW	1
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	MOVF	MES_C,W
	XORLW	2
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_28
	RETURN
	MOVF	MES_C,W
	XORLW	3
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	MOVF	MES_C,W
	XORLW	4
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_30
	RETURN
	MOVF	MES_C,W
	XORLW	5
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	MOVF	MES_C,W
	XORLW	6
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_30
	RETURN
	MOVF	MES_C,W
	XORLW	7
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	MOVF	MES_C,W
	XORLW	8
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	MOVF	MES_C,W
	XORLW	9
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_30
	RETURN
	MOVF	MES_C,W
	XORLW	10
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	MOVF	MES_C,W
	XORLW	11
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_30
	RETURN
	MOVF	MES_C,W
	XORLW	12
	BTFSS	STATUS,2
	GOTO	$+3
	CALL	INC_MES_31
	RETURN
	
	;Si DIA es mayor a 31, coloca DIA=1
	INC_MES_31:
	MOVF	DIA_C,W
	SUBLW	31	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	RETURN
	MOVLW	1
	MOVWF	DIA_C
	RETURN
	;Si DIA es mayor a 30, coloca DIA=1
	INC_MES_30:
	MOVF	DIA_C,W
	SUBLW	30	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	RETURN
	MOVLW	1
	MOVWF	DIA_C
	RETURN
	;Si DIA es mayor a 28, coloca DIA=1
	INC_MES_28:
	MOVF	DIA_C,W
	SUBLW	28	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	RETURN
	MOVLW	1
	MOVWF	DIA_C
	RETURN
	
    INC_ESTADO_2:
	BTFSS	RA5		    ; Depende la variable
	GOTO	INC_MINUTOS_TMR
	GOTO	INC_SEG_TMR
	INC_MINUTOS_TMR:
	INCF	MINUTOS_TMR_C	    ; Aumenta MinTMR
	MOVF	MINUTOS_TMR_C,W
	XORLW	100		    ; minTMR=100 limpia minTMR, minTMR no=100 regresa
	BTFSS	STATUS,2
	RETURN
	CLRF	MINUTOS_TMR_C
	RETURN
	INC_SEG_TMR:
	INCF	SEG_TMR_C	    ; Aumenta segTMR
	MOVF	SEG_TMR_C,W
	XORLW	60		    ; segTMR=60 funcion, segTMR no=60 regresa
	BTFSS	STATUS,2
	RETURN
	MOVF	MINUTOS_TMR_C,W
	XORLW	0
	BTFSS	STATUS,2	    ; Si minTMR=0 segTMR=1; Si minTMR no=0 limpia segTMR
	GOTO	$+4
	MOVLW	1
	MOVWF	SEG_TMR_C
	RETURN
	CLRF	SEG_TMR_C
	RETURN

    INC_ESTADO_3:
	BTFSS	RA5		    ; depende de la variable
	GOTO	INC_MINUTOS_ALARMA
	GOTO	INC_HORAS_ALARMA
	INC_MINUTOS_ALARMA:
	INCF	MINUTOS_ALARMA_C	; Aumentar minALARMA
	MOVF	MINUTOS_ALARMA_C,W
	XORLW	60			; Si =60 limpiar min, si no regresa
	BTFSS	STATUS,2
	RETURN
	CLRF	MINUTOS_ALARMA_C
	RETURN
	INC_HORAS_ALARMA:
	INCF	HORAS_ALARMA_C		; Aumentar horasALARMA
	MOVF	HORAS_ALARMA_C,W
	XORLW	24			; Si =24 limpiar horasALARMA, si no regresa
	BTFSS	STATUS,2
	RETURN
	CLRF	HORAS_ALARMA_C
	RETURN

INT_RB3:
    BTFSC   RE0			;Si la alarma esta encendida, apagarla. Si no, seguir
    BCF	    RE0
    BTFSS   RA4			;Si está en modo config, seguir; si no regresa
    RETURN
    ;Verificar modo
    BTFSC   RA0
    GOTO    DEC_ESTADO_0	; RELOJ
    BTFSC   RA1
    GOTO    DEC_ESTADO_1	; FECHA
    BTFSC   RA2
    GOTO    DEC_ESTADO_2	; TIMER
    BTFSC   RA3
    GOTO    DEC_ESTADO_3	; ALARMA

    DEC_ESTADO_0:
	BTFSS	RA5		    ;Verifica variable
	GOTO	DEC_MINUTOS_RELOJ
	GOTO	DEC_HORAS_RELOJ
	DEC_MINUTOS_RELOJ:
	DECF	MINUTOS_C	    ; Decrementar minutos
	BTFSS	MINUTOS_C,7	    ; Si es negativo min=59, si no regresa
	RETURN
	MOVLW	59
	MOVWF	MINUTOS_C
	RETURN
	DEC_HORAS_RELOJ:
	DECF	HORAS_C		    ; Decrementar horas
	BTFSS	HORAS_C,7	    ; Si es negativo horas=23, si no regresa
	RETURN
	MOVLW	23
	MOVWF	HORAS_C
	RETURN

    DEC_ESTADO_1:
	BTFSS	RA5		    ; Depende de la variable
	GOTO	DEC_MES_FECHA
	GOTO	DEC_DIA_FECHA
	DEC_MES_FECHA:
	DECF	MES_C		    ; Decrementa mes
	BTFSS	STATUS,2	    ; Si mes=0 mes=12, si no regresa
	RETURN
	MOVLW	12
	MOVWF	MES_C
	RETURN
	DEC_DIA_FECHA:
	DECF	DIA_C		    ; Decrementar dia
	BTFSS	STATUS,2	    ; Si dia=0, coloca 31 (para evitar colocar 31/feb se verifica en el loop)
	RETURN
	MOVLW	31
	MOVWF	DIA_C
	RETURN 
	
    DEC_ESTADO_2:
	BTFSS	RA5		    ; Depende de la variable
	GOTO	DEC_MINUTOS_TMR
	GOTO	DEC_SEG_TMR
	DEC_MINUTOS_TMR:
	DECF	MINUTOS_TMR_C	    ; Decrementa minTMR
	BTFSS	MINUTOS_TMR_C,7	    ; Si es negativo minTMR=99, si no regresa
	RETURN
	MOVLW	99
	MOVWF	MINUTOS_TMR_C
	RETURN
	DEC_SEG_TMR:
	DECF	SEG_TMR_C	    ; Decrementa segTMR
	BTFSS	SEG_TMR_C,7	    ; Si es negativo segTMR=59, si no regresa
	GOTO	$+3
	MOVLW	59
	MOVWF	SEG_TMR_C
	BTFSS	STATUS,2
	RETURN
	MOVF	MINUTOS_TMR_C,W	    
	XORLW	0		    ;Si minTMR=0 - segTMR = 59, si no regresa
	BTFSS	STATUS,2
	RETURN
	MOVLW	59
	MOVWF	SEG_TMR_C
	RETURN

    DEC_ESTADO_3:
	BTFSS	RA5			;depende de la variable
	GOTO	DEC_MINUTOS_ALARMA
	GOTO	DEC_HORAS_ALARMA
	DEC_MINUTOS_ALARMA:
	DECF	MINUTOS_ALARMA_C	;Decrementar minALARMA
	BTFSS	MINUTOS_ALARMA_C,7	;Si minALARMA negativo - minALARMA=59, si no regresa
	RETURN
	MOVLW	59
	MOVWF	MINUTOS_ALARMA_C
	RETURN
	DEC_HORAS_ALARMA:		
	DECF	HORAS_ALARMA_C		;Decrementar horasALARMA
	BTFSS	HORAS_ALARMA_C,7	;Si horasALARMA negativo - horasALARMA=23, si no regresa
	RETURN
	MOVLW	23
	MOVWF	HORAS_ALARMA_C
	RETURN

INT_RB4:
    ;verificar modo
    BTFSC   RA0
    GOTO    MODO_ESTADO_0	; RELOJ
    BTFSC   RA1
    GOTO    MODO_ESTADO_0	; FECHA
    BTFSC   RA2
    GOTO    MODO_ESTADO_0	; TIMER
    BTFSC   RA3
    GOTO    MODO_ESTADO_3	; ALARMA

    ;Es igual para reloj,fecha,timer
    MODO_ESTADO_0:
	BTFSS	RA4	;seguir si estas en modo config
	RETURN
	BTFSC	RA5	;si RA5=1 - RA5=0, si RA5=0 - RA5=1
	GOTO	$+3
	BSF	RA5
	GOTO	$+2
	BCF	RA5
    RETURN

    MODO_ESTADO_3:
	BTFSS	RA4
	GOTO	ON_OFF_ALARMA	    ;Si no estamos en el modo config ir a la func
	BTFSC	RA5
	GOTO	$+3
	BSF	RA5
	GOTO	$+2
	BCF	RA5
	RETURN
	ON_OFF_ALARMA:
	BTFSC	RA7		; si RA7=1 - RA7=0, si RA7=0 - RA7=1
	GOTO	$+3
	BSF	RA7
	RETURN
	BCF	RA7
	RETURN
RETURN

;
PSECT code, delta=2, abs
ORG 350h		    ; posición 100h para el codigo
;------------- CONFIGURACION ------------
MAIN:
    CALL    CONFIG_IO	    ; Configuración de I/O
    CALL    CONFIG_RELOJ    ; Configuración de Oscilador
    CALL    CONFIG_TMR0	    ; Configuración de TMR0
    CALL    CONFIG_TMR1	    ; Configuración de TMR1
    CALL    CONFIG_TMR2	    ; Configuración de TMR2
    CALL    CONFIG_INT	    ; Configuración de interrupciones
    BANKSEL PORTD	    ; Cambio a banco 00

LOOP:
    ; Verificar estados
    BTFSC   ESTADOS,1	;
    GOTO    $+4
    BTFSC   ESTADOS,0	;E1=0; E0=0 ESTADO_0; E0=1 ESTADO_1
    GOTO    LOOP_ESTADO_1
    GOTO    LOOP_ESTADO_0
    BTFSC   ESTADOS,0	;E1=1; E0=0 ESTADO_2; E0=1 ESTADO_3
    GOTO    LOOP_ESTADO_3
    GOTO    LOOP_ESTADO_2

    ;Encender bit estado 0
    LOOP_ESTADO_0:
    BSF	 RA0
    BCF	 RA1
    BCF	 RA2
    BCF	 RA3
    BTFSC   RA4
    GOTO    ESTADO_0_CONFIG
    GOTO    ESTADO_0_NORMAL
	; Configurar minutos y horas en el display
	ESTADO_0_NORMAL:
	CALL    OBTENER_MINUTOS
	CALL    OBTENER_HORA
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MIN
	CLRF    DECENAS_MIN
	CLRF    UNIDADES_HORA
	CLRF    DECENAS_HORA
	GOTO    LOOP
	; Configurar minutos y horas de la config en el display
	ESTADO_0_CONFIG:
	CALL    OBTENER_MINUTOS_C
	CALL    OBTENER_HORA_C
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MIN_C
	CLRF    DECENAS_MIN_C
	CLRF    UNIDADES_HORA_C
	CLRF    DECENAS_HORA_C
	GOTO LOOP

    ;Encender bit estado 1
    LOOP_ESTADO_1:
    BCF	 RA0
    BSF	 RA1
    BCF	 RA2
    BCF	 RA3

    BTFSC   RA4
    GOTO    ESTADO_1_CONFIG
    GOTO    ESTADO_1_NORMAL

	ESTADO_1_NORMAL:
	; Configurar mes y dia en el display
	CALL    OBTENER_MES
	CALL    OBTENER_DIA
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MES
	CLRF    DECENAS_MES
	CLRF    UNIDADES_DIA
	CLRF    DECENAS_DIA
	GOTO    LOOP

	ESTADO_1_CONFIG:
	;Se configuraron por defecto 31 dias
	;Chequeo meses de 30 o 28 dias, consiste en que el numero máx de dias no pase del límite de cada mes
	CHECK_FEB:
	MOVF	MES_C,W
	XORLW	2
	BTFSS	STATUS,2
	GOTO	CHECK_ABR
	MOVF	DIA_C,W
	SUBLW	28	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	GOTO	ESTADO_1_CONFIG_D
	MOVLW	28
	MOVWF	DIA_C
	GOTO	ESTADO_1_CONFIG_D
	CHECK_ABR:
	MOVF	MES_C,W
	XORLW	4
	BTFSS	STATUS,2
	GOTO	CHECK_JUN
	MOVF	DIA_C,W
	SUBLW	30	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	GOTO	ESTADO_1_CONFIG_D
	MOVLW	30
	MOVWF	DIA_C
	GOTO	ESTADO_1_CONFIG_D
	CHECK_JUN:
	MOVF	MES_C,W
	XORLW	6
	BTFSS	STATUS,2
	GOTO	CHECK_SEP
	MOVF	DIA_C,W
	SUBLW	30	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	GOTO	ESTADO_1_CONFIG_D
	MOVLW	30
	MOVWF	DIA_C
	GOTO	ESTADO_1_CONFIG_D
	CHECK_SEP:
	MOVF	MES_C,W
	XORLW	9
	BTFSS	STATUS,2
	GOTO	CHECK_NOV
	MOVF	DIA_C,W
	SUBLW	30	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	GOTO	ESTADO_1_CONFIG_D
	MOVLW	30
	MOVWF	DIA_C
	GOTO	ESTADO_1_CONFIG_D
	CHECK_NOV:
	MOVF	MES_C,W
	XORLW	11
	BTFSS	STATUS,2
	GOTO	ESTADO_1_CONFIG_D
	MOVF	DIA_C,W
	SUBLW	30	    ;C=0 DIA>31; C=1 DIA?31
	BTFSC	STATUS,0
	GOTO	ESTADO_1_CONFIG_D
	MOVLW	30
	MOVWF	DIA_C
	GOTO	ESTADO_1_CONFIG_D
	; Configurar mes y dia de la config en el display 
	ESTADO_1_CONFIG_D:
	CALL    OBTENER_MES_C
	CALL    OBTENER_DIA_C
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MES_C
	CLRF    DECENAS_MES_C
	CLRF    UNIDADES_DIA_C
	CLRF    DECENAS_DIA_C
	GOTO LOOP
    
    ;Encender bit estado 2
    LOOP_ESTADO_2:
    BCF	 RA0
    BCF	 RA1
    BSF	 RA2
    BCF	 RA3
    
    BTFSC   RA4
    GOTO    ESTADO_2_CONFIG
    GOTO    ESTADO_2_NORMAL
	; Configurar segundosTMR y minutosTMR en el display
	ESTADO_2_NORMAL:
	CALL    OBTENER_SEG_TMR
	CALL    OBTENER_MINUTOS_TMR
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MIN_TMR
	CLRF    DECENAS_MIN_TMR
	CLRF    UNIDADES_SEG_TMR
	CLRF    DECENAS_SEG_TMR
	GOTO    LOOP
	; Configurar segundosTMR y minutosTMR en la config en el display
	ESTADO_2_CONFIG:
	CALL    OBTENER_SEG_TMR_C
	CALL    OBTENER_MINUTOS_TMR_C
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MIN_TMR_C
	CLRF    DECENAS_MIN_TMR_C
	CLRF    UNIDADES_SEG_TMR_C
	CLRF    DECENAS_SEG_TMR_C
	GOTO LOOP

    ;Encender bit estado 3
    LOOP_ESTADO_3:
    BCF	 RA0
    BCF	 RA1
    BCF	 RA2
    BSF	 RA3
    
    BTFSC   RA4
    GOTO    ESTADO_3_CONFIG
    GOTO    ESTADO_3_NORMAL
	; Configurar minALARMA y segALARMA en el display
	ESTADO_3_NORMAL:
	CALL    OBTENER_MINUTOS_ALARMA
	CALL    OBTENER_HORA_ALARMA
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MIN_ALARMA
	CLRF    DECENAS_MIN_ALARMA
	CLRF    UNIDADES_HORA_ALARMA
	CLRF    DECENAS_HORA_ALARMA
	GOTO    LOOP
	; Configurar minALARMA y segALARMA en la config en el display
	ESTADO_3_CONFIG:
	CALL    OBTENER_MINUTOS_ALARMA_C
	CALL    OBTENER_HORA_ALARMA_C
	CALL    SET_DISPLAY
	CLRF    UNIDADES_MIN_ALARMA_C
	CLRF    DECENAS_MIN_ALARMA_C
	CLRF    UNIDADES_HORA_ALARMA_C
	CLRF    DECENAS_HORA_ALARMA_C
	GOTO LOOP

;------------- SUBRUTINAS ---------------
CONFIG_RELOJ:
    BANKSEL OSCCON	    ; cambiamos a banco 1
    BSF	    OSCCON, 0	    ; SCS -> 1, Usamos reloj interno
    BCF	    OSCCON, 6
    BSF	    OSCCON, 5
    BSF	    OSCCON, 4	    ; IRCF<2:0> -> 011 500kHz
    RETURN

; Configuramos el TMR0 para obtener un retardo de 2ms
CONFIG_TMR0:
    BANKSEL OPTION_REG	    ; cambiamos de banco
    BCF	    T0CS	    ; TMR0 como temporizador
    BCF	    PSA		    ; prescaler a TMR0
    BSF	    PS2
    BCF	    PS1
    BSF	    PS0		    ; PS<2:0> -> 101 prescaler 1 : 64

    BANKSEL TMR0	    ; cambiamos de banco
    MOVLW   252
    MOVWF   TMR0	    ; 2ms retardo
    BCF	    T0IF	    ; limpiamos bandera de interrupción
    RETURN

; Configuramos el TMR1 para obtener un retardo de 1000ms
CONFIG_TMR1:
    BANKSEL T1CON	    ; Cambiamos a banco 00
    BCF	    TMR1CS	    ; Reloj interno
    BCF	    T1OSCEN	    ; Apagamos LP
    BSF	    T1CKPS1	    ; Prescaler 1:8
    BSF	    T1CKPS0
    BCF	    TMR1GE	    ; TMR1 siempre contando
    BSF	    TMR1ON	    ; Encendemos TMR1

    RESET_TMR1 0xC2, 0xF7   ; TMR1 a 1000ms
    RETURN

; Configuramos el TMR2 para obtener un retardo de 100ms
CONFIG_TMR2:
    BANKSEL PR2		    ; Cambiamos a banco 01
    MOVLW   49		    ; Valor para interrupciones cada 100ms
    MOVWF   PR2		    ; Cargamos litaral a PR2

    BANKSEL T2CON	    ; Cambiamos a banco 00
    BSF	    T2CKPS1	    ; Prescaler 1:16
    BSF	    T2CKPS0

    BSF	    TOUTPS3	    ;Postscaler 1:16
    BSF	    TOUTPS2
    BSF	    TOUTPS1
    BSF	    TOUTPS0

    BSF	    TMR2ON	    ; Encendemos TMR2
    RETURN


 CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH	    ; I/O digitales
    BANKSEL TRISD
    CLRF    TRISA	    ;Puerto A como salida
    CLRF    TRISC	    ;Puerto C como salida
    MOVLW   0xF0
    MOVWF   TRISD	    ;RD0 RD1 RD2 RD3 como salida
    MOVLW   0xFE	    
    MOVWF   TRISE	    ;RE0 como salida
    MOVLW   0xFF
    MOVWF   TRISB	    ;Puerto B como entrada
    BCF	    OPTION_REG,7    ;PORTB pull-ups are enabled
    MOVLW   0x1F	    
    MOVWF   WPUB	    ; Habilita para RB0 RB1 RB2 RB3 RB4
    BANKSEL PORTD
    ;Limpiar PUERTOS
    CLRF    PORTA
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
    ;Limpiar variables
    CLRF UNIDADES_SEG
    CLRF UNIDADES_SEG
    CLRF DECENAS_SEG
    CLRF UNIDADES_MIN
    CLRF DECENAS_MIN
    CLRF UNIDADES_HORA
    CLRF DECENAS_HORA
    CLRF UNIDADES_MIN_C
    CLRF DECENAS_MIN_C
    CLRF UNIDADES_HORA_C
    CLRF DECENAS_HORA_C
    CLRF UNIDADES_MES
    CLRF DECENAS_MES	
    CLRF UNIDADES_DIA
    CLRF DECENAS_DIA	
    CLRF UNIDADES_MES_C
    CLRF DECENAS_MES_C
    CLRF UNIDADES_DIA_C
    CLRF DECENAS_DIA_C
    CLRF BANDERAS
    CLRF DISPLAY
    CLRF TEMP
    CLRF SEGUNDOS
    CLRF MINUTOS
    CLRF HORAS
    CLRF MINUTOS_C		
    CLRF HORAS_C		
    CLRF DIA		
    CLRF MES		
    CLRF DIA_C		
    CLRF MES_C		
    CLRF SEG_TMR		
    CLRF SEG_TMR_C		
    CLRF MINUTOS_TMR	
    CLRF MINUTOS_TMR_C	
    CLRF UNIDADES_MIN_TMR
    CLRF DECENAS_MIN_TMR
    CLRF UNIDADES_SEG_TMR
    CLRF DECENAS_SEG_TMR
    CLRF UNIDADES_MIN_TMR_C	
    CLRF DECENAS_MIN_TMR_C
    CLRF UNIDADES_SEG_TMR_C
    CLRF DECENAS_SEG_TMR_C
    CLRF MINUTOS_ALARMA
    CLRF HORAS_ALARMA
    CLRF MINUTOS_ALARMA_C
    CLRF HORAS_ALARMA_C
    CLRF UNIDADES_MIN_ALARMA
    CLRF DECENAS_MIN_ALARMA
    CLRF UNIDADES_HORA_ALARMA
    CLRF DECENAS_HORA_ALARMA
    CLRF UNIDADES_MIN_ALARMA_C
    CLRF DECENAS_MIN_ALARMA_C
    CLRF UNIDADES_HORA_ALARMA_C
    CLRF DECENAS_HORA_ALARMA_C
    CLRF ESTADOS
    CLRF CUENTA_SEG
    CLRF CUENTA_100ms
    CLRF CUENTA_500ms
    CLRF tCUENTA_100ms
    CLRF    HORAS
    ; Valores iniciales
    MOVLW   1
    MOVWF   DIA
    MOVLW   1
    MOVWF   MES
    MOVLW   1
    MOVWF   DIA_C
    MOVLW   1
    MOVWF   MES_C
    CLRF    MINUTOS_TMR
    CLRF    SEG_TMR
    MOVLW   1
    MOVWF   SEG_TMR_C
    CLRF    MINUTOS_ALARMA
    CLRF    HORAS_ALARMA
    RETURN

CONFIG_INT:
    BANKSEL PIE1	    ; Cambiamos a banco 01
    BSF	    TMR1IE	    ; Habilitamos int. TMR1
    BSF	    TMR2IE	    ; Habilitamos int. TMR2
    BANKSEL IOCB
    BSF	    IOCB0		; Habilitamos int. por cambio de estado en RB0
    BSF	    IOCB1		; Habilitamos int. por cambio de estado en RB1
    BSF	    IOCB2		; Habilitamos int. por cambio de estado en RB2
    BSF	    IOCB3		; Habilitamos int. por cambio de estado en RB3
    BSF	    IOCB4		; Habilitamos int. por cambio de estado en RB4
    BANKSEL INTCON	    ; Cambiamos a banco 00
    BSF	    PEIE	    ; Habilitamos int. perifericos
    BSF	    GIE		    ; Habilitamos interrupciones
    BSF	    T0IE	    ; Habilitamos interrupcion TMR0
    BCF	    T0IF	    ; Limpiamos bandera de TMR0
    BCF	    TMR1IF	    ; Limpiamos bandera de TMR1
    BCF	    TMR2IF	    ; Limpiamos bandera de TMR2
    BCF	    RBIF		; Limpiamos bandera de int. de PORTB
    RETURN

;---------------------------------------------------
; Obtener minutos por medio de la division
OBTENER_MINUTOS:
    MOVF    MINUTOS,W
    MOVWF   TEMP
    CHECK_DEC_MIN:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MIN	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MIN		;decenas = decenas+1
    GOTO    CHECK_DEC_MIN
    CHECK_UNI_MIN:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MIN		;unidades= unidades + 1
    GOTO    CHECK_UNI_MIN		;regresa a check_uni
; Obtener hora por medio de la division
OBTENER_HORA:
    MOVF    HORAS,W
    MOVWF   TEMP
    CHECK_DEC_HORA:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_HORA	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_HORA	;decenas = decenas+1
    GOTO    CHECK_DEC_HORA
    CHECK_UNI_HORA:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_HORA		;unidades= unidades + 1
    GOTO    CHECK_UNI_HORA		;regresa a check_uni

; Obtener minutos config por medio de la division
OBTENER_MINUTOS_C:
    MOVF    MINUTOS_C,W
    MOVWF   TEMP
    CHECK_DEC_MIN_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MIN_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MIN_C		;decenas = decenas+1
    GOTO    CHECK_DEC_MIN_C
    CHECK_UNI_MIN_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MIN_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_MIN_C		;regresa a check_uni
; Obtener hora config por medio de la division
OBTENER_HORA_C:
    MOVF    HORAS_C,W
    MOVWF   TEMP
    CHECK_DEC_HORA_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_HORA_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_HORA_C	;decenas = decenas+1
    GOTO    CHECK_DEC_HORA_C
    CHECK_UNI_HORA_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_HORA_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_HORA_C		;regresa a check_uni

;---------------------------------------------------
; Obtener mes por medio de la division
OBTENER_MES:
    MOVF    MES,W
    MOVWF   TEMP
    CHECK_DEC_MES:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MES	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MES		;decenas = decenas+1
    GOTO    CHECK_DEC_MES
    CHECK_UNI_MES:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MES		;unidades= unidades + 1
    GOTO    CHECK_UNI_MES		;regresa a check_uni
; Obtener dia por medio de la division
OBTENER_DIA:
    MOVF    DIA,W
    MOVWF   TEMP
    CHECK_DEC_DIA:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_DIA	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_DIA	;decenas = decenas+1
    GOTO    CHECK_DEC_DIA
    CHECK_UNI_DIA:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_DIA		;unidades= unidades + 1
    GOTO    CHECK_UNI_DIA		;regresa a check_uni
; Obtener mes config por medio de la division
OBTENER_MES_C:
    MOVF    MES_C,W
    MOVWF   TEMP
    CHECK_DEC_MES_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MES_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MES_C		;decenas = decenas+1
    GOTO    CHECK_DEC_MES_C
    CHECK_UNI_MES_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MES_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_MES_C		;regresa a check_uni
; Obtener dia config por medio de la division
OBTENER_DIA_C:
    MOVF    DIA_C,W
    MOVWF   TEMP
    CHECK_DEC_DIA_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_DIA_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_DIA_C	;decenas = decenas+1
    GOTO    CHECK_DEC_DIA_C
    CHECK_UNI_DIA_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_DIA_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_DIA_C		;regresa a check_uni
;--------------------------------
; Obtener minutosTMR por medio de la division
OBTENER_MINUTOS_TMR:
    MOVF    MINUTOS_TMR,W
    MOVWF   TEMP
    CHECK_DEC_MIN_TMR:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MIN_TMR	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MIN_TMR		;decenas = decenas+1
    GOTO    CHECK_DEC_MIN_TMR
    CHECK_UNI_MIN_TMR:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MIN_TMR		;unidades= unidades + 1
    GOTO    CHECK_UNI_MIN_TMR		;regresa a check_uni
; Obtener segTMR por medio de la division
OBTENER_SEG_TMR:
    MOVF    SEG_TMR,W
    MOVWF   TEMP
    CHECK_DEC_SEG_TMR:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_SEG_TMR	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_SEG_TMR	;decenas = decenas+1
    GOTO    CHECK_DEC_SEG_TMR
    CHECK_UNI_SEG_TMR:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_SEG_TMR		;unidades= unidades + 1
    GOTO    CHECK_UNI_SEG_TMR		;regresa a check_uni
; Obtener minutosTMR config por medio de la division
OBTENER_MINUTOS_TMR_C:
    MOVF    MINUTOS_TMR_C,W
    MOVWF   TEMP
    CHECK_DEC_MIN_TMR_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MIN_TMR_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MIN_TMR_C		;decenas = decenas+1
    GOTO    CHECK_DEC_MIN_TMR_C
    CHECK_UNI_MIN_TMR_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MIN_TMR_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_MIN_TMR_C		;regresa a check_uni
; Obtener segundosTMR config por medio de la division
OBTENER_SEG_TMR_C:
    MOVF    SEG_TMR_C,W
    MOVWF   TEMP
    CHECK_DEC_SEG_TMR_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_SEG_TMR_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_SEG_TMR_C	;decenas = decenas+1
    GOTO    CHECK_DEC_SEG_TMR_C
    CHECK_UNI_SEG_TMR_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_SEG_TMR_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_SEG_TMR_C		;regresa a check_uni

;---------------------------------------------------
; Obtener minutosALARMA por medio de la division
OBTENER_MINUTOS_ALARMA:
    MOVF    MINUTOS_ALARMA,W
    MOVWF   TEMP
    CHECK_DEC_MIN_ALARMA:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MIN_ALARMA	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MIN_ALARMA		;decenas = decenas+1
    GOTO    CHECK_DEC_MIN_ALARMA
    CHECK_UNI_MIN_ALARMA:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MIN_ALARMA		;unidades= unidades + 1
    GOTO    CHECK_UNI_MIN_ALARMA		;regresa a check_uni
; Obtener horasALARMA por medio de la division
OBTENER_HORA_ALARMA:
    MOVF    HORAS_ALARMA,W
    MOVWF   TEMP
    CHECK_DEC_HORA_ALARMA:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_HORA_ALARMA	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_HORA_ALARMA	;decenas = decenas+1
    GOTO    CHECK_DEC_HORA_ALARMA
    CHECK_UNI_HORA_ALARMA:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_HORA_ALARMA		;unidades= unidades + 1
    GOTO    CHECK_UNI_HORA_ALARMA		;regresa a check_uni
; Obtener minutosALARMA config por medio de la division
OBTENER_MINUTOS_ALARMA_C:
    MOVF    MINUTOS_ALARMA_C,W
    MOVWF   TEMP
    CHECK_DEC_MIN_ALARMA_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si 10>MINUTOS,  C=0 CHECK_UNI, ; 10=<MINUTOS, C=1 funcion
    GOTO    CHECK_UNI_MIN_ALARMA_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_MIN_ALARMA_C		;decenas = decenas+1
    GOTO    CHECK_DEC_MIN_ALARMA_C
    CHECK_UNI_MIN_ALARMA_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_MIN_ALARMA_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_MIN_ALARMA_C		;regresa a check_uni
; Obtener horasALARMA config por medio de la division
OBTENER_HORA_ALARMA_C:
    MOVF    HORAS_ALARMA_C,W
    MOVWF   TEMP
    CHECK_DEC_HORA_ALARMA_C:
    MOVLW   10			; W=10
    SUBWF   TEMP,W		; valor - 10
    BTFSS   STATUS,0		; Si W>f,  C=0 CHECK_UNI, ; W=<f, C=1 funcion
    GOTO    CHECK_UNI_HORA_ALARMA_C	;
    MOVWF   TEMP		;valor = valor - 10
    INCF    DECENAS_HORA_ALARMA_C	;decenas = decenas+1
    GOTO    CHECK_DEC_HORA_ALARMA_C
    CHECK_UNI_HORA_ALARMA_C:
    MOVLW   1			; W=1
    SUBWF   TEMP,W		; valor - 1
    BTFSS   STATUS,0		; Si W>f, C=0, ; W?f, C=1
    RETURN			; Retorna
    MOVWF   TEMP		;valor = valor - 1
    INCF    UNIDADES_HORA_ALARMA_C		;unidades= unidades + 1
    GOTO    CHECK_UNI_HORA_ALARMA_C		;regresa a check_uni

;---------------------------------------------------
    
SET_DISPLAY:
    ;Verificar modo
    ; En cada modo se setea el valor dependiendo si es normal o de configuracion
    BTFSC   RA0
    GOTO    SET_HORA
    BTFSC   RA1
    GOTO    SET_FECHA
    BTFSC   RA2
    GOTO    SET_HORA_TMR
    BTFSC   RA3
    GOTO    SET_HORA_ALARMA
    
    SET_HORA:
	BTFSC	RA4
	GOTO	SET_HORA_CONFIG
	GOTO	SET_HORA_NORMAL
	SET_HORA_CONFIG:
	MOVF    UNIDADES_MIN_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_MIN_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_HORA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_HORA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
	SET_HORA_NORMAL:
	MOVF    UNIDADES_MIN, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_MIN, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_HORA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_HORA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
    SET_FECHA:
	BTFSC	RA4
	GOTO	SET_FECHA_CONFIG
	GOTO	SET_FECHA_NORMAL
	SET_FECHA_CONFIG:
	MOVF    UNIDADES_MES_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_MES_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_DIA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_DIA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
	SET_FECHA_NORMAL:
	MOVF    UNIDADES_MES, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_MES, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_DIA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_DIA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
    SET_HORA_TMR:
	BTFSC	RA4
	GOTO	SET_HORA_TMR_CONFIG
	GOTO	SET_HORA_TMR_NORMAL
	SET_HORA_TMR_CONFIG:
	MOVF    UNIDADES_SEG_TMR_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_SEG_TMR_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_MIN_TMR_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_MIN_TMR_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
	SET_HORA_TMR_NORMAL:
	MOVF    UNIDADES_SEG_TMR, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_SEG_TMR, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_MIN_TMR, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_MIN_TMR, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
    SET_HORA_ALARMA:
	BTFSC	RA4
	GOTO	SET_HORA_ALARMA_CONFIG
	GOTO	SET_HORA_ALARMA_NORMAL
	SET_HORA_ALARMA_CONFIG:
	MOVF    UNIDADES_MIN_ALARMA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_MIN_ALARMA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_HORA_ALARMA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_HORA_ALARMA_C, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN
	SET_HORA_ALARMA_NORMAL:
	MOVF    UNIDADES_MIN_ALARMA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+3
	MOVF    DECENAS_MIN_ALARMA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+2
	MOVF    UNIDADES_HORA_ALARMA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY+1
	MOVF    DECENAS_HORA_ALARMA, W
	CALL    TABLA_7SEG
	MOVWF   DISPLAY
	RETURN

MOSTRAR_VALORES:
    BCF	    PORTD, 0		; Apagamos display de centenas
    BCF	    PORTD, 1		; Apagamos display de decenas
    BCF	    PORTD, 2		; Apagamos display de decenas
    BCF	    PORTD, 3
    
    ;Verifica si es modo normal o de config
    BTFSS   RA4
    GOTO MOSTRAR_NORMAL
    GOTO MOSTRAR_CONFIG
    ; El modo config titilea 
    MOSTRAR_CONFIG:
    BTFSC   CUENTA_100ms,0
    GOTO    $+2
    GOTO    MOSTRAR_NORMAL
    CLRF    PORTC
    RETURN
    ; Mostrar normal 
    MOSTRAR_NORMAL:
    BTFSS   CUENTA_500ms,0
    GOTO    CHECK_BANDERAS_DISPLAY
    BSF	    DISPLAY,7
    BSF	    DISPLAY+1,7
    BSF	    DISPLAY+2,7
    BSF	    DISPLAY+3,7
    ; Depende de las banderas nos movemos al display
    CHECK_BANDERAS_DISPLAY:
    BTFSC   BANDERAS,1	;
    GOTO    $+4
    BTFSC   BANDERAS,0	;B1=0; B0=0 ESTADO_0; B0=1 ESTADO_1
    GOTO    DISPLAY_1
    GOTO    DISPLAY_0
    BTFSC   BANDERAS,0	;B1=1; B0=0 ESTADO_2; B0=1 ESTADO_3
    GOTO    DISPLAY_3
    GOTO    DISPLAY_2
    DISPLAY_0:
	MOVF    DISPLAY, W	; Movemos display a W
	MOVWF   PORTC		; Movemos Valor de tabla a PORTC
	BSF	PORTD, 0	;
	BCF	BANDERAS,1	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BSF	BANDERAS,0	;
    RETURN
    DISPLAY_1:
	MOVF    DISPLAY+1, W	; Movemos display a W
	MOVWF   PORTC		; Movemos Valor de tabla a PORTC
	BSF	PORTD, 1	;
	BSF	BANDERAS,1	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	BANDERAS,0	;
    RETURN
    DISPLAY_2:
	MOVF    DISPLAY+2, W	; Movemos display a W
	MOVWF   PORTC		; Movemos Valor de tabla a PORTC
	BSF	PORTD, 2	;
	BSF	BANDERAS,1	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BSF	BANDERAS,0
    RETURN
    DISPLAY_3:
	MOVF    DISPLAY+3, W	; Movemos display a W
	MOVWF   PORTC		; Movemos Valor de tabla a PORTC
	BSF	PORTD, 3	;
	BCF	BANDERAS,1	; Cambiamos bandera para cambiar el otro display en la siguiente interrupción
	BCF	BANDERAS,0
    RETURN

ORG 300h
TABLA_7SEG:
    CLRF    PCLATH		; Limpiamos registro PCLATH
    BSF	    PCLATH, 0		; Posicionamos el PC en dirección 02xxh
    BSF	    PCLATH, 1
    ANDLW   0x0F		; no saltar más del tamaño de la tabla
    ADDWF   PCL
    RETLW   00111111B	;0
    RETLW   00000110B	;1
    RETLW   01011011B	;2
    RETLW   01001111B	;3
    RETLW   01100110B	;4
    RETLW   01101101B	;5
    RETLW   01111101B	;6
    RETLW   00000111B	;7
    RETLW   01111111B	;8
    RETLW   01101111B	;9
    RETLW   01110111B	;A
    RETLW   01111100B	;b
    RETLW   00111001B	;C
    RETLW   01011110B	;d
    RETLW   01111001B	;E
    RETLW   01110001B	;F