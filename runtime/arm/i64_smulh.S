@ *****************************************************************
@
@               The Compcert verified compiler
@
@           Xavier Leroy, INRIA Paris
@
@ Copyright (c) 2016 Institut National de Recherche en Informatique et
@  en Automatique.
@
@ Redistribution and use in source and binary forms, with or without
@ modification, are permitted provided that the following conditions are met:
@     * Redistributions of source code must retain the above copyright
@       notice, this list of conditions and the following disclaimer.
@     * Redistributions in binary form must reproduce the above copyright
@       notice, this list of conditions and the following disclaimer in the
@       documentation and/or other materials provided with the distribution.
@     * Neither the name of the <organization> nor the
@       names of its contributors may be used to endorse or promote products
@       derived from this software without specific prior written permission.
@
@ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
@ "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
@ LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
@ A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT
@ HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
@ EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
@ PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
@ PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
@ LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
@ NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
@
@ *********************************************************************

@ Helper functions for 64-bit integer arithmetic.  ARM version.

#include "sysdeps.h"

@@@ Multiply-high signed

@ Hacker's Delight section 8.3:
@ - compute high 64 bits of the unsigned product X * Y  (see i64_umulh.S)
@ - subtract X if Y < 0
@ - subtract Y if X < 0

FUNCTION(__compcert_i64_smulh)
        push  {r4, r5, r6, r7}
@@@ r7:r6 accumulate bits 95-32 of the full product	
        umull r4, r6, Reg0LO, Reg1LO   @ r6 = high half of XL.YL product
	umull r4, r5, Reg0LO, Reg1HI   @ r5:r4 = product XL.YH
        adds  r6, r6, r4
        ADC   r7, r5, #0               @ no carry out
	umull r4, r5, Reg0HI, Reg1LO   @ r5:r4 = product XH.YL
        adds  r6, r6, r4
        adcs  r7, r7, r5               @ carry out is possible
@@@ r6:r7 accumulate bits 127-64 of the full product
        mov   r6, #0
        ADC   r6, r6, #0               @ put carry out in bits 127-96
	umull r4, r5, Reg0HI, Reg1HI   @ r5:r4 = product XH.YH
        adds  r7, r7, r4
        ADC   r6, r6, r5
@@@ subtract X if Y < 0
        cmp   Reg1HI, #0
        bge   1f
        subs  r7, r7, Reg0LO
        sbcs  r6, r6, Reg0HI
@@@ subtract Y if X < 0
1:      cmp   Reg0HI, #0
        bge 2f
        subs  r7, r7, Reg1LO
        sbcs  r6, r6, Reg1HI
@@@ return result in Reg0 pair
2:      mov   Reg0LO, r7
        mov   Reg0HI, r6
        pop   {r4, r5, r6, r7}
        bx    lr
ENDFUNCTION(__compcert_i64_smulh)
