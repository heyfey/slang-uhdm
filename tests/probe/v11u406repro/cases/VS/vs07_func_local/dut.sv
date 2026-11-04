// § arrElemVarKind406
module top;
  function automatic int f();
    string s [2];
    real r [2];
    s[0] = "a";
    return $size(s);
  endfunction
  int x;
  initial x = f();
endmodule
