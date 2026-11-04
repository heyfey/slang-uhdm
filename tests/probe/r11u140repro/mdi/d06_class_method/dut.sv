// § multiDeclOneItem140
class cx;
  function int f();
    int i, r;
    r = 0;
    for (i = 0; i < 4; i++) r = r + 1;
    return r;
  endfunction
endclass
module top;
  cx o;
  initial begin
    o = new();
    $display("%0d", o.f());
  end
endmodule
