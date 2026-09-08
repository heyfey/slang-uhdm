// ARM H — THE MUST-STAY CONTROL.  An out-of-body method of a package class
// whose formals and locals are ORDINARY resolvable types (a package typedef,
// an int, a string, a queue).  Nothing here is a placeholder, so no cell of
// this arm may move in either view.
package p213h;
  typedef bit [7:0] b213_t;
  class c213h;
    extern function void fh213(b213_t x213, int i213, string s213);
    extern function void gh213();
  endclass
  function void c213h::fh213(b213_t x213, int i213, string s213);
    b213_t loch213;
    int    lochi213;
    loch213 = x213;
    lochi213 = i213;
  endfunction
  function void c213h::gh213();
    b213_t q213[$];
    q213.push_back(8'h0);
  endfunction
endpackage
module top213h;
  initial begin end
endmodule
