// r10vbuvm25 — adversarial foreach package-array grid.
// Varies container aliases, class spellings, dimensions, declaration homes,
// written qualification, function/task bodies and both def/elab views.
package va25;
  class Alpha25;
    int value;
  endclass
  class Generic25 #(type T = int);
    T value;
  endclass
  virtual class Abstract25;
    pure virtual function void ping();
  endclass

  typedef Alpha25 AlphaAlias25;
  typedef Alpha25 QueueAlias25[$];
  typedef QueueAlias25 QueueAliasChain25;
  typedef Alpha25 DynamicAlias25[];
  typedef Alpha25 FixedAlias25[4];

  QueueAlias25 q_alias;
  QueueAliasChain25 q_alias_chain;
  DynamicAlias25 d_alias;
  FixedAlias25 f_alias;
  AlphaAlias25 q_element_alias[$];
  Generic25#(byte) q_parameterized[$];
  Abstract25 q_abstract[$];
  Alpha25 q_direct[$];
  Alpha25 d_direct[];
  Alpha25 f_direct[3];
  Alpha25 matrix_q[2][$];
  Alpha25 matrix_f[2][3];

  function void free_function25();
    foreach (q_alias[ix_q_alias]) q_alias[ix_q_alias].value = ix_q_alias;
    foreach (q_alias_chain[ix_q_chain]) q_alias_chain[ix_q_chain].value = ix_q_chain;
    foreach (d_alias[ix_d_alias]) d_alias[ix_d_alias].value = ix_d_alias;
    foreach (f_alias[ix_f_alias]) f_alias[ix_f_alias].value = ix_f_alias;
    foreach (q_element_alias[ix_e_alias]) q_element_alias[ix_e_alias].value = ix_e_alias;
    foreach (q_parameterized[ix_param]) q_parameterized[ix_param].value = ix_param;
    foreach (q_abstract[ix_abs]) q_abstract[ix_abs].ping();
    foreach (matrix_q[ix_mq0, ix_mq1]) begin end
    foreach (matrix_f[ix_mf0, ix_mf1]) matrix_f[ix_mf0][ix_mf1].value = ix_mf1;
    foreach (matrix_f[ix_mf_empty,]) begin end
    foreach (va25::q_direct[ix_qualified]) q_direct[ix_qualified].value = ix_qualified;
  endfunction

  task free_task25;
    foreach (d_direct[ix_task]) d_direct[ix_task].value = ix_task;
  endtask

  class Holder25;
    Alpha25 class_queue[$];
    function void method25();
      foreach (class_queue[ix_class]) class_queue[ix_class].value = ix_class;
    endfunction
  endclass
endpackage

package vb25;
  import va25::Alpha25;
  import va25::QueueAlias25;
  typedef va25::Alpha25 ForeignAlias25;
  typedef va25::QueueAlias25 ForeignQueueAlias25;

  Alpha25 q_imported_element[$];
  ForeignAlias25 d_foreign_alias[];
  QueueAlias25 q_imported_container;
  ForeignQueueAlias25 q_foreign_container_alias;

  function void foreign_home25();
    foreach (q_imported_element[ix_imp_e]) q_imported_element[ix_imp_e].value = ix_imp_e;
    foreach (d_foreign_alias[ix_for_e]) d_foreign_alias[ix_for_e].value = ix_for_e;
    foreach (q_imported_container[ix_imp_c]) q_imported_container[ix_imp_c].value = ix_imp_c;
    foreach (q_foreign_container_alias[ix_for_c]) q_foreign_container_alias[ix_for_c].value = ix_for_c;
    // Cross-package reference: the array declaration is not homed here.
    foreach (va25::q_direct[ix_cross]) va25::q_direct[ix_cross].value = ix_cross;
  endfunction
endpackage

va25::Alpha25 unit_queue[$];
function void unit_function25();
  foreach (unit_queue[ix_unit]) unit_queue[ix_unit].value = ix_unit;
endfunction

module module_home25;
  import va25::*;
  Alpha25 module_queue[$];
  function void module_function25();
    foreach (module_queue[ix_module]) module_queue[ix_module].value = ix_module;
  endfunction
endmodule

interface interface_home25;
  import va25::Alpha25;
  Alpha25 interface_queue[$];
  function void interface_function25();
    foreach (interface_queue[ix_interface]) interface_queue[ix_interface].value = ix_interface;
  endfunction
endinterface

program program_home25;
  import va25::Alpha25;
  Alpha25 program_queue[$];
  function void program_function25();
    foreach (program_queue[ix_program]) program_queue[ix_program].value = ix_program;
  endfunction
endprogram
