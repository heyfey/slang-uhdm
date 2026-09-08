// r10v222 — probe: a receiver written in PARENTHESES.
interface if22r;
   function void poke22r(string a_name, int a_kind);
   endfunction
endinterface
class hold22r;
   virtual if22r vif22r;
   function void r01_parenrecv(string a_s);
      (vif22r).poke22r(a_s, 1);
   endfunction
endclass
module mod22r;
   hold22r h22r;
endmodule
