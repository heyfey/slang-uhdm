// v5: PACKAGE-NAME PREFIX traps (buvm18 R-V1): w / work@, a / ab, chain1 / chain12.
package w;
  parameter int PW = 64;
  typedef logic signed [PW-1:0] t_t;
  class CW; extern function t_t r(); endclass
  function t_t CW::r(); r = 'b0; endfunction
endpackage
package a;
  parameter int PW = 64;
  typedef logic signed [PW-1:0] t_t;
  class CA; extern function t_t r(); endclass
  function t_t CA::r(); r = 'b0; endfunction
endpackage
package ab;
  parameter int PW = 64;
  typedef logic signed [PW-1:0] t_t;
  class CAB; extern function t_t r(); extern function a::t_t rq(); endclass
  function t_t CAB::r(); r = 'b0; endfunction
  function a::t_t CAB::rq(); rq = 'b0; endfunction
endpackage
package chain1;
  parameter int PW = 64;
  typedef logic signed [PW-1:0] t_t;
  class C1; extern function t_t r(); endclass
  function t_t C1::r(); r = 'b0; endfunction
endpackage
package chain12;
  import chain1::*;
  parameter int PW = 64;
  typedef logic signed [PW-1:0] u_t;
  class C12; extern function u_t r(); extern function chain1::t_t rq(); endclass
  function u_t C12::r(); r = 'b0; endfunction
  function chain1::t_t C12::rq(); rq = 'b0; endfunction
endpackage

module work;
  import w::*; import a::*; import ab::*;
  w::t_t x;
  w::CW cw; ab::CAB cab; chain12::C12 c12;
  initial begin cw=new(); cab=new(); c12=new(); x = cw.r() + cab.r() + c12.r(); end
endmodule
