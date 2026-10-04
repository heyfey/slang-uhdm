// § pureVirtRetSpecWholeSpan234: $unit classes
class comp; endclass
virtual class vis #(type N = int); endclass
virtual class cs;
  pure virtual function vis#(comp) get_v();
endclass
module top; endmodule
