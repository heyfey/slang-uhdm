// r10uvm202 arm E — THE CORPUS HEAD, MINIMISED.  THE POSITIVE CONTROL.
//
// uvm-1.2 shape, transcribed construct for construct:
//   reg/uvm_reg_cbs.svh:334  typedef uvm_callback_iter#(uvm_mem,       uvm_reg_cbs) uvm_mem_cb_iter;
//   reg/uvm_reg_cbs.svh:354  typedef uvm_callback_iter#(uvm_reg_field, uvm_reg_cbs) uvm_reg_field_cb_iter;
//   reg/uvm_reg_field.svh:1128 (a `begin` of the UVM_PREDICT_WRITE case item of
//                              the out-of-body method uvm_reg_field::do_predict)
//                              uvm_reg_field_cb_iter cbs = new(this);
// read in `adpcm_pkg` / `svaunit_pkg`, the packages that write
// `import uvm_pkg::*;`.
//
// The two specialisation typedefs of ONE generic class are BOTH here on
// purpose: they are what makes the name-first of the group the base and the
// other a span-borrowing alias clone, and this arm is where that is scored.
package uvmish202e;
  class RegField202e;
    int val202e;
  endclass
  class Mem202e;
    int val202e;
  endclass
  class RegCbs202e;
    int val202e;
  endclass
  class CallbackIter202e #(type T202e = int, type CB202e = int);
    T202e owner202e;
    function new(T202e o202e = null);
      owner202e = o202e;
    endfunction
  endclass

  typedef CallbackIter202e#(Mem202e,      RegCbs202e) memCbIter202e;   // name-first: the BASE
  typedef CallbackIter202e#(RegField202e, RegCbs202e) fieldCbIter202e; // the head's type

  class RegFieldImpl202e;
    extern function void doPredict202e(int kind202e);
  endclass

  function void RegFieldImpl202e::doPredict202e(int kind202e);
    case (kind202e)
      0: begin
        fieldCbIter202e cbs202e = new(null);    // <- THE HEAD
        memCbIter202e   mcbs202e = new(null);
        if (cbs202e == null) mcbs202e = null;
      end
      default: ;
    endcase
  endfunction
endpackage

package adpcmish202e;               // the importing package: `import uvm_pkg::*;`
  import uvmish202e::*;
  class Seq202e;
    function void body202e();
      RegFieldImpl202e f202e;
      f202e = null;
    endfunction
  endclass
endpackage
