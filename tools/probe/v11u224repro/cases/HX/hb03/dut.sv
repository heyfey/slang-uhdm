// § hpLvNewClassFirstElemSpan224
class s; endclass
class r; s parent; endclass
interface ifc;
  r rw;
  task t(); rw = new; rw.parent = new; endtask
endinterface
module top; ifc u(); initial u.t(); endmodule
