import uvm_pkg::*;
`include "uvm_macros.svh"

class req_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(req_sequence_item)

    rand logic [7:0] command;
    rand int delay;

    constraint c_delay {delay >= 0; delay <= 10;}

    function new(string name = "req_sequence_item");
        super.new(name);
    endfunction : new
endclass : req_sequence_item

class rsp_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(rsp_sequence_item)
    
    rand logic [2:0] status;
    rand int delay;

    constraint c_delay {delay >= 0; delay <= 10;}

    function new(string name = "rsp_sequence_item");
        super.new(name);
    endfunction : new
endclass : rsp_sequence_item

class req_sequencer extends uvm_sequencer#(req_sequence_item);
    `uvm_component_utils(req_sequencer)

    function new(string name = "req_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass : req_sequencer

class rsp_sequencer extends uvm_sequencer#(rsp_sequence_item);
    `uvm_component_utils(rsp_sequencer)

    function new(string name = "rsp_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass : rsp_sequencer

class req_driver extends uvm_driver#(req_sequence_item);
    `uvm_component_utils(req_driver)

    function new(string name = "req_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        req_sequence_item req;

        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info(get_type_name(), $sformatf("Processing request: command=%0d, delay=%0d", req.command, req.delay), UVM_LOW)   
            
            seq_item_port.item_done();
        end
    endtask : run_phase
endclass : req_driver

class rsp_driver extends uvm_driver#(rsp_sequence_item);
    `uvm_component_utils(rsp_driver)

    function new(string name = "rsp_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        rsp_sequence_item rsp;

        forever begin
            seq_item_port.get_next_item(rsp);

            `uvm_info(get_type_name(), $sformatf("Processing response: status=%0d, delay=%0d", rsp.status, rsp.delay), UVM_LOW)

            seq_item_port.item_done();
        end
    endtask : run_phase
endclass : rsp_driver

class req_sequence extends uvm_sequence#(req_sequence_item);
    `uvm_object_utils(req_sequence)

    rand logic [7:0] command;
    rand int delay;

    req_sequence_item req;

    function new(string name = "req_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, {command == this.command; delay == this.delay;})
    endtask : body
endclass : req_sequence

class rsp_sequence extends uvm_sequence#(rsp_sequence_item);
    `uvm_object_utils(rsp_sequence)

    rand logic [2:0] status;
    rand int delay;

    rsp_sequence_item rsp;

    function new(string name = "rsp_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(rsp, {status == this.status; delay == this.delay;})
    endtask : body
endclass : rsp_sequence

class base_virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);
    `uvm_component_utils(base_virtual_sequencer)

    req_sequencer m_req_sequencer;
    rsp_sequencer m_rsp_sequencer;

    function new(string name = "base_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass : base_virtual_sequencer

class req_rsp_sequence extends uvm_sequence;
    `uvm_object_utils(req_rsp_sequence)
    `uvm_declare_p_sequencer(base_virtual_sequencer)

    req_sequence_item req;
    rsp_sequence_item rsp;

    function new(string name = "req_rsp_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_on(req, p_sequencer.m_req_sequencer)
        `uvm_do_on(rsp, p_sequencer.m_rsp_sequencer)
        `uvm_do_on(req, p_sequencer.m_req_sequencer)
    endtask : body
endclass : req_rsp_sequence

class base_env extends uvm_env;
    `uvm_component_utils(base_env)

    req_sequencer m_req_sequencer;
    req_driver m_req_driver;

    rsp_sequencer m_rsp_sequencer;
    rsp_driver m_rsp_driver;

    base_virtual_sequencer m_virtual_sequencer;

    function new(string name = "base_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_req_sequencer = req_sequencer::type_id::create("m_req_sequencer", this);
        m_req_driver = req_driver::type_id::create("m_req_driver", this);

        m_rsp_sequencer = rsp_sequencer::type_id::create("m_rsp_sequencer", this);
        m_rsp_driver = rsp_driver::type_id::create("m_rsp_driver", this);

        m_virtual_sequencer = base_virtual_sequencer::type_id::create("m_virtual_sequencer", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        m_req_driver.seq_item_port.connect(m_req_sequencer.seq_item_export);
        m_rsp_driver.seq_item_port.connect(m_rsp_sequencer.seq_item_export);

        m_virtual_sequencer.m_req_sequencer = m_req_sequencer;
        m_virtual_sequencer.m_rsp_sequencer = m_rsp_sequencer;
    endfunction: connect_phase
endclass

class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    base_env env;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = base_env::type_id::create("env", this);
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        req_rsp_sequence req_rsp_seq;

        phase.raise_objection(this);

        req_rsp_seq = req_rsp_sequence::type_id::create("req_rsp_seq");
        req_rsp_seq.start(env.m_virtual_sequencer);

        phase.drop_objection(this);
    endtask : run_phase
endclass