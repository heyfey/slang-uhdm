// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  logic [3:0] ben;
endinterface
module child (bus_if sub, input logic [1:0] s, output logic o);
  function automatic logic pick(input logic [1:0] k);
    return sub.ben[k] ^ sub.ben[s];
  endfunction
  assign o = pick(s);
endmodule
module top (input logic [3:0] ben_i, input logic [1:0] s, output logic o);
  bus_if sub ();
  assign sub.ben = ben_i;
  child c (.sub(sub), .s(s), .o(o));
endmodule
