// r10uvm57repro/a1_witness.sv -- THE WITNESS, reduced from uvm-1.2
// src/base/uvm_registry.svh:257-262: a variable declared inside an UNNAMED
// begin/end statement block that is the body of an `if`, inside a CLASS METHOD.
class reg_c;
  static function int create(int obj);
    create = obj;
    if (obj == 0) begin
      string msg;
      msg = "Factory did not return an object of type";
      $display(msg);
    end
  endfunction
endclass

module a1_witness;
  reg_c rc;
  initial rc = null;
endmodule
