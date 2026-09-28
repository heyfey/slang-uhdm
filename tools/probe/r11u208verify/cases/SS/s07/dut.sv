// § tfSigningSpanFollowsCompilePath200
interface ifc;
  function automatic byte unsigned f(input int signed k);
    return k;
  endfunction
endinterface
program prg;
  function automatic longint signed g(input time unsigned t);
    return t;
  endfunction
  initial $display(g(5));
endprogram
module s07(output logic [7:0] y);
  ifc i();
  prg p();
  assign y = i.f(3);
endmodule
