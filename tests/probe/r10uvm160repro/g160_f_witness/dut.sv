// r10uvm160 grid, arm F — THE REDUCED CORPUS WITNESSES.
// `uvm-1.2/src/reg/uvm_reg_predictor.svh:54,117-124` (the head) and
// `uvm-1.2/src/base/uvm_misc.svh:702-731`'s `uvm_utils::get_config` (the other
// twenty-three-cell half), cut down to one file.  PRISTINE: uhdm-cmp reports
// 67 cmp lines and ONE `^LHS:` on the `pred160` half alone — the SAME 67 the
// corpus rows report, because a cmp line count is the head object's decompile
// size.  PATCHED: 0 lines, 0 heads, CMP_EQUAL.  MEASUREMENT ONLY.
// (the `define sits on the LAST comment line's own line: a blank line here
//  makes Surelog's coverage writer report `UHDM coverage pointing to empty
//  source line` and exit 4 with the database still complete.)
`define warn160(ID, MSG) rep160f(ID, MSG);
package pf160;
  class basef160;
    function new(string name="x"); endfunction
    function string get_name160(); return "n"; endfunction
  endclass

  // --- the HEAD: uvm_reg_predictor #(type BUSTYPE=int)::get_type_name
  class pred160 #(type BUSTYPE=int) extends basef160;
    static string tname160 = "";
    virtual function string get_name160();
      if (tname160 == "") begin
        BUSTYPE t;
        t = BUSTYPE::type_id::create("t");
        tname160 = {"pred160 #(", t.get_type_name(), ")"};
      end
      return tname160;
    endfunction
  endclass

  // --- the OTHER twenty-three-cell half: uvm_utils #(type TYPE=int,
  //     string FIELD="config")::get_config, where the concatenation is a CALL
  //     ARGUMENT and the bad operand is a `::`-scoped name on the type
  //     parameter, beside an ACCEPTED twin built from the same operand kinds.
  class utils160 #(type TYPE=int, string FIELD="config");
    static string ures160 = "";
    static function void rep160(string id, string msg); ures160 = msg; endfunction
    static function void get_config160(bit is_fatal);
      // the ACCEPTED twin (every operand binds)
      rep160("NO_SET_CFG", {"no set_config to field '", FIELD, "'"});
      // the REJECTED one (`TYPE::type_name` is bad for TYPE = int)
      rep160("GET_CFG_TYPE_FAIL", {"set_config_object with field name ", FIELD,
                           " is not of type '", TYPE::type_name, "'"});
    endfunction
  endclass

  // --- the MACRO face: `uvm_utils::find`'s `\`uvm_warning({...})`
  //     (uvm_misc.svh:663-664 and :674-675).  The concatenation is written as
  //     a MACRO ARGUMENT, and the two producers report its objects at
  //     DIFFERENT locations — golden at the macro BODY, ours at the macro
  //     ARGUMENT — which is why the whole-dump diff shows sixteen span-only
  //     lines on each uvm-1.2 row and why this cell exists: no generated
  //     `Compare` reads VpiLineNo/VpiColumnNo (RESUME.md §9), so the judge must
  //     call this database EQUAL.
  class warn160c #(type TYPE=int);
    static string wres160 = "";
    static function void rep160f(string id, string msg); wres160 = msg; endfunction
    static function void find160(basef160 start);
      `warn160("find_type-no match", {"Instance of type '", TYPE::type_name,
         " not found in component hierarchy beginning at ", start.get_name160()})
    endfunction
  endclass
endpackage

module topf160;
  initial $display("hi");
endmodule
