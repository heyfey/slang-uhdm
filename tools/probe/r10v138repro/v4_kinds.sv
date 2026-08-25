// V4 — ENUM KINDS x explicit values, all through the BARE-RETURN face in the
// package free-function home.  Negative, non-contiguous, based, unsized.
package v4p;
   typedef enum { K1_A, K1_B }                          k1_t;   // no base
   typedef enum int { K2_A, K2_B }                      k2_t;
   typedef enum int unsigned { K3_A, K3_B }             k3_t;
   typedef enum bit [3:0] { K4_A, K4_B }                k4_t;
   typedef enum logic [7:0] { K5_A, K5_B }              k5_t;
   typedef enum byte { K6_A, K6_B }                     k6_t;
   typedef enum shortint { K7_A, K7_B }                 k7_t;
   typedef enum longint { K8_A, K8_B }                  k8_t;
   typedef enum int { K9_A = -3, K9_B = -1 }            k9_t;   // NEGATIVE
   typedef enum int { KA_A = 1, KA_B = 5, KA_C }        ka_t;   // NON-CONTIGUOUS + resumed
   typedef enum bit [3:0] { KB_A = 4'hB, KB_B = 4'd9 }  kb_t;   // hex + based-dec
   typedef enum bit [1:0] { KC_A = 2'b10, KC_B = 2'b01 } kc_t;  // binary
   typedef enum int { KD_A = 9, KD_B = 12 }             kd_t;   // unsized decimal
   typedef enum bit [7:0] { KE_A = 8'o20, KE_B = 8'o7 } ke_t;   // OCTAL
   typedef enum int { KF_A = 'd6, KF_B = 'd7 }          kf_t;   // UNSIZED based
   typedef enum int { KG_A = 1 << 2, KG_B }             kg_t;   // expression init
   typedef enum { KH_A[3] }                             kh_t;   // range spec

   function k1_t f1(); return K1_B; endfunction
   function k2_t f2(); return K2_B; endfunction
   function k3_t f3(); return K3_B; endfunction
   function k4_t f4(); return K4_B; endfunction
   function k5_t f5(); return K5_B; endfunction
   function k6_t f6(); return K6_B; endfunction
   function k7_t f7(); return K7_B; endfunction
   function k8_t f8(); return K8_B; endfunction
   function k9_t f9(); return K9_A; endfunction
   function k9_t f9b(); return K9_B; endfunction
   function ka_t fa(); return KA_C; endfunction
   function ka_t fab(); return KA_B; endfunction
   function kb_t fb(); return KB_A; endfunction
   function kb_t fbb(); return KB_B; endfunction
   function kc_t fc(); return KC_A; endfunction
   function kd_t fd(); return KD_A; endfunction
   function ke_t fe(); return KE_A; endfunction
   function kf_t ff(); return KF_A; endfunction
   function kg_t fg(); return KG_B; endfunction
   function kh_t fh(); return KH_A1; endfunction
endpackage

module v4top;
   int i;
   initial begin
      i = v4p::f1(); i = v4p::f2(); i = v4p::f3(); i = v4p::f4(); i = v4p::f5();
      i = v4p::f6(); i = v4p::f7(); i = v4p::f8(); i = v4p::f9(); i = v4p::f9b();
      i = v4p::fa(); i = v4p::fab(); i = v4p::fb(); i = v4p::fbb(); i = v4p::fc();
      i = v4p::fd(); i = v4p::fe(); i = v4p::ff(); i = v4p::fg(); i = v4p::fh();
   end
endmodule
