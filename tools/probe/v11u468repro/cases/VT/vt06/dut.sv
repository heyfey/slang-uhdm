// § specArgTypedefNameShares468
class C #(type T = int, type U = int);
  T m;
endclass
class D;
  typedef D this_type;
  function void g();
    C #(int, this_type) loc;
  endfunction
endclass
module top; D d; endmodule
