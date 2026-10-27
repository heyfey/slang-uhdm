// § sysCallEmptyArgEndPrevTok441
interface ifc;
  logic a;
  task t;
    $display("x", a,
             , a);
  endtask
endinterface
module top;
  ifc u();
  initial u.t();
endmodule
