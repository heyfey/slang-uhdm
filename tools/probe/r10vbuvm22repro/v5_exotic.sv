// r10vbuvm22 verifier grid v5 — the EXOTIC scopes and spellings: a typedef in a
// GENERATE block, a wildcard associative index, importers ABSENT (fully scoped
// use), a task with an output arg, an extern-in-$unit class, and the same
// package used from THREE module instances.
package p5;
  class base5; int x; endclass
  typedef int ti5_t;
  typedef base5 pq_cls5[$];
  typedef ti5_t pq_tdint5[$];
  typedef int   pq_int5[$];
  typedef int   pw_int5[*];        // WILDCARD associative index
  typedef ti5_t pw_tdint5[*];
  function automatic pw_int5   f_pw_int();   pw_int5 r;   return r; endfunction
  function automatic pw_tdint5 f_pw_tdint(); pw_tdint5 r; return r; endfunction
endpackage

// IMPORTERS ABSENT: everything named with a full scope, no `import`
module noimp5;
  function automatic p5::pq_cls5   f_ni_cls();   p5::pq_cls5 r;   return r; endfunction
  function automatic p5::pq_tdint5 f_ni_tdint(); p5::pq_tdint5 r; return r; endfunction
  function automatic p5::pq_int5   f_ni_int();   p5::pq_int5 r;   return r; endfunction
  class nic5;
    function p5::pq_cls5   m_ni_cls();   p5::pq_cls5 r;   return r; endfunction
    function p5::pq_tdint5 m_ni_tdint(); p5::pq_tdint5 r; return r; endfunction
    function p5::pq_int5   m_ni_int();   p5::pq_int5 r;   return r; endfunction
  endclass
endmodule

// a typedef inside a GENERATE block
module gen5;
  parameter int N = 2;
  for (genvar g = 0; g < N; g++) begin : blk
    typedef int      g_q_int5[$];
    typedef p5::ti5_t g_q_tdint5[$];
    typedef p5::base5 g_q_cls5[$];
    function automatic g_q_int5   f_g_int();   g_q_int5 r;   return r; endfunction
    function automatic g_q_tdint5 f_g_tdint(); g_q_tdint5 r; return r; endfunction
    function automatic g_q_cls5   f_g_cls();   g_q_cls5 r;   return r; endfunction
  end
endmodule

// a task with an OUTPUT arg of the same typedef, plus a void function
module tsk5;
  import p5::*;
  typedef int    t_q_int5[$];
  typedef p5::ti5_t t_q_tdint5[$];
  task automatic tk_out(output t_q_int5 o); endtask
  task automatic tk_out2(output t_q_tdint5 o); endtask
  function automatic void vf5(); endfunction
  function automatic t_q_int5   f_t_int();   t_q_int5 r;   return r; endfunction
  function automatic t_q_tdint5 f_t_tdint(); t_q_tdint5 r; return r; endfunction
endmodule

// THREE instances of the same module
module inner5;
  import p5::*;
  typedef p5::base5 i_q_cls5[$];
  typedef p5::ti5_t i_q_tdint5[$];
  typedef int       i_q_int5[$];
  function automatic i_q_cls5   f_i_cls();   i_q_cls5 r;   return r; endfunction
  function automatic i_q_tdint5 f_i_tdint(); i_q_tdint5 r; return r; endfunction
  function automatic i_q_int5   f_i_int();   i_q_int5 r;   return r; endfunction
endmodule

module top5;
  inner5 u0();
  inner5 u1();
  inner5 u2();
  noimp5 n0();
  gen5   g0();
  tsk5   t0();
endmodule
