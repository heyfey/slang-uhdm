// r10uvm57repro/a8_negctrl.sv -- THE NEGATIVE CONTROL.  A block with NO
// declarations must gain nothing; a FUNCTION-level (not block-level) local must
// keep exactly what it has today.
class neg_c;
  static function int f(int obj);
    string fnlocal;             // FUNCTION-level local -- must not change
    fnlocal = "fn";
    f = obj;
    if (obj == 0) begin         // block with NO declarations -- gains nothing
      f = 1;
      $display(fnlocal);
    end
    if (obj == 1) begin : nb    // named block, NO declarations
      f = 2;
    end
  endfunction
endclass

module a8_negctrl;
  int w;
  task automatic mt();
    string tlocal;
    tlocal = "t";
    if (w == 0) begin
      $display(tlocal);
    end
  endtask
  initial begin
    if (w == 0) begin
      w = 1;
    end
  end
  neg_c nc;
  initial nc = null;
endmodule
