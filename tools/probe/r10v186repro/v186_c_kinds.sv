// r10v186 (VERIFIER) ARM C — THE RECEIVER-KIND AND ARGUMENT-TYPE AXIS.
//
// r10uvm186's corpus population is `int` dynamic arrays sized by `int`
// locals and copied from `int` arrays.  The lifted gate names no type at all,
// so the kinds the brief calls out — a STRING array, a non-string scalar
// array, a QUEUE, an ASSOCIATIVE array, a class-handle array, a struct array,
// a multi-dimensional array — must each be asked of a real golden in the
// clone listing.  The QUEUE and the ASSOCIATIVE array appear both as the
// SIZE-expression source (`new[q.size()]`, `new[aa[key]]`) and, for the queue,
// as the COPY SOURCE of `new[n](src)`, which IEEE 1800 allows.
//
// Names, numbers and orders deliberately unlike the corpus' and unlike
// r10uvm186's own arms.
package Astragal186v;

  typedef struct packed { int hi; int lo; } cusp186v_t;

  class Finial186v;
    int m_tip;
  endclass

  function automatic int chamfer186v(input int in_a, input string in_s);
    int        idyn186v[];              // the corpus' own kind
    string     sdyn186v[];              // a STRING dynamic array
    byte       bdyn186v[];              // a non-int scalar array
    logic [7:0] ldyn186v[];             // a 4-state vector array
    cusp186v_t cdyn186v[];              // a STRUCT array
    Finial186v hdyn186v[];              // a CLASS-HANDLE array
    int        mdyn186v[][];            // a MULTI-DIMENSIONAL dynamic array

    int    ring186v[$];                 // a QUEUE
    int    lock186v[string];            // an ASSOCIATIVE array
    int    seed186v;
    int    isrc186v[];
    string ssrc186v[];
    string key186v;

    seed186v = in_a + 1;
    key186v  = in_s;
    ring186v.push_back(2);
    lock186v[key186v] = 3;
    isrc186v = new[2];
    ssrc186v = new[2];

    idyn186v = new[seed186v];           // K1  int array, int local (control)
    sdyn186v = new[seed186v];           // K2  a STRING array receiver
    bdyn186v = new[seed186v];           // K3  a BYTE array receiver
    ldyn186v = new[seed186v];           // K4  a 4-state vector array receiver
    cdyn186v = new[seed186v];           // K5  a STRUCT array receiver
    hdyn186v = new[seed186v];           // K6  a CLASS-HANDLE array receiver
    mdyn186v = new[seed186v];           // K7  a MULTI-DIM array receiver

    idyn186v = new[ring186v.size()];    // K8  a QUEUE method as the size
    idyn186v = new[lock186v[key186v]];  // K9  an ASSOC select, index a local
    idyn186v = new[ring186v[0]];        // K10 a QUEUE select, constant index

    idyn186v = new[seed186v](isrc186v); // K11 COPY SOURCE, an int array
    sdyn186v = new[seed186v](ssrc186v); // K12 COPY SOURCE, a STRING array

    return idyn186v.size() + sdyn186v.size() + bdyn186v.size() +
           ldyn186v.size() + cdyn186v.size() + hdyn186v.size() +
           mdyn186v.size();
  endfunction

  function automatic int scarf186v(input int in_b, ref int rq186v[$],
                                   ref int ra186v[string]);
    int dyn186v[];
    string k2186v;
    k2186v = "x";
    dyn186v = new[rq186v.size()];       // K13 a QUEUE FORMAL as the size source
    dyn186v = new[ra186v[k2186v]];      // K14 an ASSOC FORMAL select
    dyn186v = new[in_b];                // K15 the plain control
    return dyn186v.size();
  endfunction

endpackage

package Cavetto186v;
  import Astragal186v::*;
  function automatic int use_cavetto186v();
    int    q186v[$];
    int    a186v[string];
    q186v.push_back(4);
    a186v["y"] = 5;
    return chamfer186v(1, "z") + scarf186v(2, q186v, a186v);
  endfunction
endpackage

module top186vc;
  import Cavetto186v::*;
  int reading186v;
  initial begin
    reading186v = use_cavetto186v();
    $display("%0d", reading186v);
  end
endmodule
