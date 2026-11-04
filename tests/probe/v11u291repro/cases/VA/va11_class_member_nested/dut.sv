// § anonAggMemberChainName291
class cc;
  struct packed { struct packed { logic a; logic b; } [1:0] m; } v;
  function logic f(); return v.m[0].a; endfunction
endclass
module dut (output logic o);
  initial begin cc h = new; o = h.f(); end
endmodule
