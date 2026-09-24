// § classMethodQualSpan144
class C;
  int x;
  local function new();
    x = 1;
  endfunction
  static
    function int s();
      return 2;
    endfunction
  virtual protected task vt();
    x = 3;
  endtask
  virtual function C clone();
    return null;
  endfunction
endclass
module top; endmodule
