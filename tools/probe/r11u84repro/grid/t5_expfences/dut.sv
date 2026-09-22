// r11u84 t5 - THE TWO FENCES, RECORDED AS MEASURED FACTS, NOT SCORED.
// (a) Surelog v1.87 ERRORS on an explicit import of an entry whose declared
//     type is a typedef the same explicit item does NOT carry over:
//     `importPackage` filters the DATATYPE map by `object_name` too
//     (CompileHelper.cpp:163-169), so the cloned signal's type name has
//     nothing to bind to in the importing scope -- `[ERR:CP0317] Undefined
//     type`.  MEASURED: a struct-with-an-`int` typedef, an `enum` typedef and
//     a `bit` typedef all error; a `logic`/`reg` typedef and an ALL-LOGIC
//     struct typedef do not.  GOLDEN WRITES NOTHING WORTH FOLLOWING on an
//     error run, so those spellings are not this law's ground.
// (b) A CHAINED explicit import (`import s2::n` where s2 WILDCARD-imported n)
//     is accepted by Surelog and REJECTED by slang ("no member named 'n' in
//     package 's2'"), so that shape is unreachable through our front end.
// This arm carries (a) only -- (b) cannot be compiled by us at all.
package f1;
  typedef struct packed { int a; logic b; } fs_t;
  fs_t  f_struct;
  typedef enum logic [1:0] {F0,F1} fe_t;
  fe_t  f_enum;
  typedef bit [7:0] fb_t;
  fb_t  f_bit;
endpackage
package f2;  import f1::f_struct;  logic [7:0] g2; endpackage
package f3;  import f1::f_enum;    logic [7:0] g3; endpackage
package f4;  import f1::f_bit;     logic [7:0] g4; endpackage
module dut (output logic [31:0] o);
  import f2::*; import f3::*; import f4::*;
  assign o = {24'd0, g2 ^ g3 ^ g4};
endmodule
