// § clsMethodOwnAutomatic462
class C;
  protected function automatic int f(); return 1; endfunction
  local task automatic t(); endtask
endclass
module top;
  initial begin C c; c = new; end
endmodule
