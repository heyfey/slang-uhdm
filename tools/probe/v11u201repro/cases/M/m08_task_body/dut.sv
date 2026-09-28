// § methodArgNestedRefChain201
interface bus_if;
  function automatic int f(int v); return v; endfunction
endinterface
module top;
  bus_if b();
  int a[4];
  int r, i;
  task automatic t(int k);
    r = b.f(a[k] + i);
  endtask
  always @(i) begin
    r = b.f(a[i] - 1);
    t(i);
  end
endmodule
