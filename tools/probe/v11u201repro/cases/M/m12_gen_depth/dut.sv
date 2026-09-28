// § methodArgNestedRefChain201
interface bus_if;
  function automatic int f(int v); return v; endfunction
endinterface
module leaf(bus_if b);
  int a[4];
  int r, i;
  if (1) begin : g1
    case (1)
      1: begin : c1
        always @(i) r = b.f(a[i] + 1);
      end
    endcase
  end
endmodule
module mid(bus_if b);
  for (genvar k = 0; k < 2; k++) begin : gl
    leaf u(.b(b));
  end
endmodule
module top;
  bus_if b();
  mid m(.b(b));
endmodule
