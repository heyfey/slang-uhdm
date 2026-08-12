// b2_formal — AXIS 2: the FORMAL's TYPE, actual always the bare decimal `1`,
// caller always a CLASS METHOD (the head's scope).  F1 bit, F2 logic[3:0],
// F3 int, F4 byte, F5 string(control: already bare by strFormalConst),
// F6 bit[63:0], F7 logic (1-bit, no range), F8 signed byte.
package p62;
   function void f1_bit   (bit b);            endfunction
   function void f2_vec4  (logic [3:0] b);    endfunction
   function void f3_int   (int b);            endfunction
   function void f4_byte  (byte b);           endfunction
   function void f5_str   (string b);         endfunction
   function void f6_vec64 (bit [63:0] b);     endfunction
   function void f7_logic (logic b);          endfunction
   function void f8_sbyte (byte signed b);    endfunction

   class c62;
      function void call_all();
         f1_bit(1);
         f2_vec4(1);
         f3_int(1);
         f4_byte(1);
         f5_str("s");
         f6_vec64(1);
         f7_logic(1);
         f8_sbyte(1);
      endfunction
   endclass
endpackage

module b2_formal;
   import p62::*;
   // The SAME eight calls from a MODULE FUNCTION — the non-class control row.
   function void mod_call_all();
      f1_bit(1);
      f2_vec4(1);
      f3_int(1);
      f4_byte(1);
      f5_str("s");
      f6_vec64(1);
      f7_logic(1);
      f8_sbyte(1);
   endfunction
   initial mod_call_all();
endmodule
