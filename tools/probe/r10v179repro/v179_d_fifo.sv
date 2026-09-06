// r10v179 ADVERSARIAL ARM D — THE CORPUS SHAPE ITSELF, reproduced from
// uvm-1.2 (`uvm_sequencer_param_base::send_request` / `uvm_sequencer::item_done`)
// as a QUEUE-BACKED try_put/try_get PAIR, plus the same package emitted with
// ONE, TWO and THREE importing instances so the def listing and every
// elaborated copy can be counted.  MEASUREMENT ONLY.
package pkg_whisky;

  class Item;
    int seq_no;
  endclass

  // The uvm_tlm_fifo stand-in: try_put / try_get / try_peek, all user methods.
  class Fifo #(type MSG = Item);
    MSG store[$];
    function bit try_put(MSG m); store.push_back(m); return 1; endfunction
    function bit try_get(ref MSG m);
      if (store.size() == 0) return 0;
      m = store.pop_front();
      return 1;
    endfunction
    function bit try_peek(MSG m); return store.size() != 0; endfunction
    task put_blocking(MSG m); store.push_back(m); endtask
  endclass

  class SeqBase #(type REQ = Item);
    Fifo #(REQ) m_req_fifo;
    int         beat;

    // uvm_sequencer_param_base::send_request, verbatim shape.
    extern function void send_request(int rerandomize);
    // uvm_sequencer::item_done, verbatim shape.
    extern function void item_done();
    // try_peek in the same window.
    extern function void peek_here();
    // the BLOCKING (task) twin, statement position.
    extern task          push_here();
    // the try_put call in STATEMENT position — must stay BOUND.
    extern function void put_stmt();
  endclass

  function void SeqBase::send_request(int rerandomize);
    REQ param_t;
    if (m_req_fifo.try_put(param_t) != 1) beat = 1;      // v01 THE CORPUS CELL
  endfunction

  function void SeqBase::item_done();
    REQ t;
    if (m_req_fifo.try_get(t) == 0) beat = 2;            // v02 THE SIBLING
  endfunction

  function void SeqBase::peek_here();
    REQ pk;
    if (m_req_fifo.try_peek(pk) == 0) beat = 3;          // v03
  endfunction

  task SeqBase::push_here();
    REQ blk;
    m_req_fifo.put_blocking(blk);                        // v04 statement, task
  endtask

  function void SeqBase::put_stmt();
    REQ st;
    void'(m_req_fifo.try_put(st));                       // v05 statement-ish
  endfunction

endpackage

module tb_whisky_one;
  import pkg_whisky::*;
  SeqBase #(Item) s1;
  initial s1 = new();
endmodule

module tb_whisky_two;
  import pkg_whisky::*;
  SeqBase #(Item) s2a;
  SeqBase #(Item) s2b;
  initial begin s2a = new(); s2b = new(); end
endmodule

module tb_whisky_three;
  import pkg_whisky::*;
  SeqBase #(Item) s3a;
  SeqBase #(Item) s3b;
  SeqBase #(Item) s3c;
  initial begin s3a = new(); s3b = new(); s3c = new(); end
endmodule
