function automatic integer m_rcmp(integer v);  return v > 3;      endfunction
function automatic integer m_acmp(integer v);  m_acmp = v > 3;    endfunction
function automatic integer m_rand(integer v);  return v && 1;     endfunction
function automatic integer m_aand(integer v);  m_aand = v && 1;   endfunction
function automatic integer m_ror(integer v);   return v || 0;     endfunction
function automatic integer m_aor(integer v);   m_aor = v || 0;    endfunction
function automatic integer m_acat(integer v);  m_acat = {4'h5,4'h5}; endfunction
function automatic integer m_arep(integer v);  m_arep = {2{4'ha}};   endfunction
function automatic integer m_asub(integer v);  m_asub = v - 1;    endfunction
function automatic integer m_aneg(integer v);  m_aneg = -v;       endfunction
function automatic integer m_asgn(integer v);  m_asgn = $signed(v); endfunction
function automatic integer m_atern(integer v); m_atern = (v==1) ? 1 : 2; endfunction
module s5 #(parameter int NB = 300) (output logic o);
  localparam int i_rcmp  = m_rcmp(NB);
  localparam int i_acmp  = m_acmp(NB);
  localparam int i_rand  = m_rand(NB);
  localparam int i_aand  = m_aand(NB);
  localparam int i_ror   = m_ror(NB);
  localparam int i_aor   = m_aor(NB);
  localparam int i_acat  = m_acat(NB);
  localparam int i_arep  = m_arep(NB);
  localparam int i_asub  = m_asub(NB);
  localparam int i_aneg  = m_aneg(NB);
  localparam int i_asgn  = m_asgn(NB);
  localparam int i_atern = m_atern(NB);
  localparam     u_rcmp  = m_rcmp(NB);
  localparam     u_acmp  = m_acmp(NB);
  localparam     u_rand  = m_rand(NB);
  localparam     u_aand  = m_aand(NB);
  localparam     u_acat  = m_acat(NB);
  localparam     u_arep  = m_arep(NB);
  localparam     u_asub  = m_asub(NB);
  localparam     u_aneg  = m_aneg(NB);
  localparam     u_asgn  = m_asgn(NB);
  localparam byte b_acmp = m_acmp(NB);
  localparam byte b_rcmp = m_rcmp(NB);
  assign o = 1'b0;
endmodule
module t5 (output logic o); s5 #(.NB(300)) u5 (.o(o)); endmodule
