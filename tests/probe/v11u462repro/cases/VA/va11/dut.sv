// § clsMethodOwnAutomatic462
virtual class V;
  pure virtual task pt();
  task automatic t(); endtask
endclass
class C extends V;
  task pt(); endtask
endclass
module top;
  initial begin C c; c = new; end
endmodule
