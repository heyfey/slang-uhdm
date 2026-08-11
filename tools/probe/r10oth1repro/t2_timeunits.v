module mtop;
   parameter a_fs = 7fs;
   parameter b_ps = 7ps;
   parameter c_ns = 7ns;
   parameter d_us = 7us;
   parameter e_ms = 7ms;
   parameter f_s  = 7s;
   parameter g_frac = 1.5ns;
   // ADDED BY THE PASS-46/47-ERA VERIFIER AUDIT.  The README's LAW-1 gate
   // paragraph cited a "t_real row" and an int control in this file as proof the
   // !typedParam gate is not too wide, and the file HAD NEITHER -- a claim
   // resting on an asset that does not exist.  The claim itself is true (the
   // verifier measured it separately), so the asset is added rather than the
   // claim deleted.  Expected against golden: t_real keeps real_typespec +
   // REAL:123.450000, t_int stays an ordinary int.
   parameter t_real = 123.45;
   parameter t_int  = 5;
endmodule
