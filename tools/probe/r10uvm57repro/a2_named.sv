// r10uvm57repro/a2_named.sv -- a NAMED block with the same declaration.
// Does the block name enter the variable's vpiFullName?
class named_c;
  static function int f(int obj);
    f = obj;
    if (obj == 0) begin : blk
      string msg;
      msg = "x";
      $display(msg);
    end
    if (obj == 1) begin      // unnamed twin, same function, same var name
      string msg2;
      msg2 = "y";
      $display(msg2);
    end
  endfunction
endclass

module a2_named;
  named_c nc;
  initial nc = null;
endmodule
