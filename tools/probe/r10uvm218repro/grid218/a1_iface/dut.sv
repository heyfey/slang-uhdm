// r10uvm218 arm a1 — the binder window of an UNINSTANTIATED interface's
// subroutine body, against an INSTANTIATED interface and a MODULE control.
// Every cell is one reference; the question is whether golden gives it a
// vpiActual.
package p218;
   typedef enum { E218_A, E218_B } e218_t;
endpackage

class c218;
   function void set_it(string nm, bit en);
   endfunction
endclass

interface if218_un;                       // NEVER instantiated
   import p218::*;
   bit gvar218;
   c218 h218;

   function void plain218(string a_nm, bit a_en, int a_rs);
      bit lvar218;
      e218_t lenum218;
      lvar218 = a_en;                     // u01 assign RHS, formal
      gvar218 = lvar218;                  // u02 assign RHS, body local
      if (a_nm == "x") begin              // u03 if CONDITION, formal
         gvar218 = 1'b1;
      end
      if (lvar218) begin                  // u04 if CONDITION, body local
         gvar218 = 1'b0;
      end
      if (a_rs inside {1, 2}) begin       // u05 `inside` CONDITION, formal
         gvar218 = 1'b1;
      end
      if (lenum218 inside {E218_A}) begin // u06 `inside` CONDITION, local enum var
         gvar218 = 1'b1;
      end
      case (a_rs)                         // u07 CASE condition, formal
        0: gvar218 = 1'b1;
        default: gvar218 = 1'b0;
      endcase
      callee218(a_nm);                    // u08 CALL-STATEMENT arg, formal
      callee218b(lvar218);                // u09 CALL-STATEMENT arg, body local
      h218.set_it(a_nm, a_en);            // u10/u11 RECEIVER-qualified call args
      gvar218 = fn218(a_en);              // u12 call arg in EXPRESSION position
   endfunction

   function void callee218(string s); endfunction
   function void callee218b(bit b); endfunction
   function bit  fn218(bit b); return b; endfunction

   task plain218t(string a_nm);
      callee218(a_nm);                    // u13 task, call-statement arg
      if (a_nm == "y") gvar218 = 1'b1;    // u14 task, if condition
   endtask
endinterface

interface if218_in;                       // INSTANTIATED below
   bit gvar218i;
   c218 h218i;
   function void plain218i(string a_nm, bit a_en, int a_rs);
      bit lvar218i;
      lvar218i = a_en;                    // i01
      gvar218i = lvar218i;                // i02
      if (a_nm == "x") gvar218i = 1'b1;   // i03
      if (a_rs inside {1, 2}) gvar218i = 1'b1; // i05
      callee218i(a_nm);                   // i08
      h218i.set_it(a_nm, a_en);           // i10/i11
   endfunction
   function void callee218i(string s); endfunction
endinterface

module m218_ctl;                          // MODULE control
   bit gvar218m;
   c218 h218m;
   function void plain218m(string a_nm, bit a_en, int a_rs);
      bit lvar218m;
      lvar218m = a_en;                    // m01
      gvar218m = lvar218m;                // m02
      if (a_nm == "x") gvar218m = 1'b1;   // m03
      if (a_rs inside {1, 2}) gvar218m = 1'b1; // m05
      callee218m(a_nm);                   // m08
      h218m.set_it(a_nm, a_en);           // m10/m11
   endfunction
   function void callee218m(string s); endfunction
endmodule

module top218;
   if218_in the_if();                     // instantiates if218_in ONLY
endmodule
