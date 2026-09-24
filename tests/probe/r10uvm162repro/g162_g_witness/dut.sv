// r10uvm162 grid, arm G — THE REDUCED CORPUS WITNESS.
//
// `uvm-1.2/src/base/uvm_registry.svh:558-570`, which BuildUVMPkg's preprocessed
// `uvm_pkg.sv` carries at `:14055-14065`, reduced to what makes the head: a
// GENERIC class whose type parameters default to `int`, a twelve-operand
// message with TWO ternaries in it, each holding a null comparison, a string
// constant and a dotted call, and the `::`-qualified operands beside them.
//
// Pristine this file's concatenation is an `operation` with an EMPTY operand
// vector — the `RHS: <null>` head; patched it is golden's twelve operands.
// MEASUREMENT ONLY.
package uvm_pkg162;

  class uvm_component162;
    function new(string name="x"); endfunction
    function string get_type_name(); return "c"; endfunction
    function string get_full_name(); return "f"; endfunction
  endclass

  class uvm_object162;
    function string get_type_name(); return "o"; endfunction
  endclass

  class uvm_registry_common162 #(type Tregistry=int, type Tcreator=int,
                                 type Tcreated=int);

    static function Tcreated create(string name, uvm_component162 parent,
                                    string contxt);
      uvm_object162 obj;
      string msg;
      msg = {"Factory did not return a ", Tcreator::base_type_name(), " of type '",Tregistry::type_name,
        "'. A component of type '",obj == null ? "null" : obj.get_type_name(),
        "' was returned instead. Name=",name," Parent=",
        parent==null?"null":parent.get_type_name()," contxt=",contxt};
    endfunction

  endclass

endpackage

module top162;
  initial $display("hi");
endmodule
