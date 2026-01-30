module hazard_unit(
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [8:0] decoded_instruction,
    input logic [4:0] ex_rd,
    input logic ex_load_inst,
    input logic jump_branch_taken,
    input logic invalid_inst,
    input logic stall,

    output logic if_id_pipeline_flush,
    output logic if_id_pipeline_en,
    output logic id_ex_pipeline_flush,
    output logic id_ex_pipeline_en,
    output logic pc_en,
    output logic load_stall,
    output logic ex_mem_pipeline_en,
    output logic ex_mem_pipeline_flush,
    output logic mem_wb_pipeline_en
);

    logic id_rs1_used;
    logic id_rs2_used;

    logic rs1_hazard;
    logic rs2_hazard;
    logic load_hazard;

    // decoded_instruction = {r_type_inst, i_type_inst, mem_write, wb_load, u_type_inst, b_type_inst, j_type_inst, aupic_inst, jalr_inst};
    // For load we need to check if rs1 or rs2 is actually used in the instruction
    assign id_rs2_used = decoded_instruction[8] || decoded_instruction[6] || decoded_instruction[3];
    assign id_rs1_used = id_rs2_used || decoded_instruction[7] || 
                        decoded_instruction[5] || decoded_instruction[0];

    assign rs1_hazard = id_rs1_used && (id_rs1 == ex_rd);
    assign rs2_hazard = id_rs2_used && (id_rs2 == ex_rd);
    assign load_hazard = ex_load_inst && (ex_rd != 5'b0) && (rs1_hazard || rs2_hazard);
     
    // At one time only 1 of `ex_load_inst` or `jump_branch_taken` will be true
    always_comb begin
        //  Default values to avoid latch
        if_id_pipeline_flush = 1'b0;
        if_id_pipeline_en = 1'b1;
        id_ex_pipeline_flush = 1'b0;
        id_ex_pipeline_en = 1'b1;
        pc_en = 1'b1;
        load_stall = 1'b0;
        ex_mem_pipeline_en = 1'b1;
        ex_mem_pipeline_flush = 1'b0;
        mem_wb_pipeline_en = 1'b1;

        // Jump/Branch taken flush - 3 Flush
        if (jump_branch_taken) begin
            if_id_pipeline_flush = 1'b1;
            id_ex_pipeline_flush = 1'b1;
            ex_mem_pipeline_flush = 1'b1;

        // Load flush - 1 Stall
        end else if (load_hazard) begin
            if_id_pipeline_en = 1'b0;
            id_ex_pipeline_flush = 1'b1;
            pc_en = 1'b0;
            load_stall = 1'b1;
        end

        else if (stall) begin
            if_id_pipeline_en = 1'b0;
            id_ex_pipeline_en = 1'b0;
            pc_en = 1'b0;
        end

        else if (invalid_inst) begin
            id_ex_pipeline_flush = 1'b1;
        end

    end

endmodule