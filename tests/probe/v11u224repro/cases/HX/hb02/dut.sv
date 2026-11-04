// § hpLvNewClassFirstElemSpan224
class s; endclass
class r; s parent; endclass
module leaf; r rw; initial begin rw = new; rw.parent = new; end endmodule
module mid; leaf l(); endmodule
module top; mid m(); endmodule
