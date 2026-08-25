// r10uvm141 arm C -- NAME COLLISIONS x INSTANCE COUNTS for the stub.
//
// The stub loses its vpiName, so two stubs in DIFFERENT classes are
// distinguishable only by owner; this arm checks that a name shared with a
// package free function, with a built-in method name, and with a system
// function's spelling changes nothing, and that 1/2/3 instances of the owning
// class (and 1/2/3 specializations of a parameterized one) do not multiply or
// merge the object in either view.  Names are deliberately NOT a uniform
// a_t/b_t/c_t grid: an arm that names everything alike is self-confirming.
package p141c;

  function automatic int ceil(int a);          // package free function `ceil`
    int q = a;
    return q;
  endfunction

  class Kollide;
    local function automatic int ceil(int a);  // SAME name as the package fn
      int r = a;
      int r0 = a + 1;
      return r0 ? r : r0;
    endfunction
  endclass

  class Sizey;
    local function automatic int size(int n);   // built-in method spelling
      int acc = n;
      return acc;
    endfunction
    protected function automatic int num(int n);// another built-in spelling
      int tally = n;
      return tally;
    endfunction
  endclass

  class Dollarish;
    local function automatic int clog2(int wid);// $clog2 without the $
      int lg = wid;
      return lg;
    endfunction
  endclass

  class Threepeat;                              // instantiated 3x below
    local function automatic int weigh(int g);
      int scale = g;
      return scale;
    endfunction
  endclass

  class Onceonly;                               // instantiated 1x
    local function automatic int weigh(int g);
      int scale = g;
      return scale;
    endfunction
  endclass

  class Parm #(int W = 4);                      // 3 specializations below
    local function automatic int span(int v);
      int held = v + W;
      return held;
    endfunction
  endclass

endpackage

module t141c;
  p141c::Threepeat r1, r2, r3;
  p141c::Onceonly  s1;
  p141c::Kollide   k1;
  p141c::Sizey     z1;
  p141c::Dollarish d1;
  p141c::Parm #(4) w4;
  p141c::Parm #(9) w9;
  p141c::Parm #(17) w17;
  initial begin
    r1 = new(); r2 = new(); r3 = new();
    s1 = new(); k1 = new(); z1 = new(); d1 = new();
    w4 = new(); w9 = new(); w17 = new();
    $display("%0d", p141c::ceil(3));
  end
endmodule
