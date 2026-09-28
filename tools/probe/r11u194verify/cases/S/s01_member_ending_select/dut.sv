// § streamLvMemberPathRead184: streaming lvalues whose operand is a member path ending in a select (r11v184's residue R3 shape), with a slice size, in a class method, beside a member path through two selects
package pk;
  typedef struct { logic [7:0] f [4]; } s_t;
  class c;
    s_t s;
    function void unpack(logic [15:0] x, int k);
      {>>{s.f[k]}} = x[7:0];
      {<<4{s.f[k + 1]}} = x[15:8];
    endfunction
  endclass
endpackage
module top (input logic [15:0] x, input int k, output logic [7:0] o);
  typedef struct { logic [7:0] f [4]; } s_t;
  typedef struct { s_t w [2]; } m_t;
  s_t s;
  m_t m;
  always_comb begin
    {>>{s.f[k]}} = x[7:0];
    {>>{m.w[k].f[k]}} = x[15:8];
  end
  assign o = s.f[0];
endmodule
