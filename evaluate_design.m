function [L_Loss, T_max]] = evaluate_design(index, I_L1_rms, I_L1_pp, T_ambient, duty_cycle, h_convection, fsw)
%EVALUATE_DESIGN  Your MATLAB model for ONE design. Runs on a pool worker.
%   spec is whatever you passed from Python (number, array, struct, ...).
%   Replace the body with your real model.
    
    % Reconstruct geom:
    geom = cell2struct(cellfun(@(f) fom.geom.(f)(index), fn_geom, 'UniformOutput', false),fn_geom);

    % Reconstruct material:
    material = cell2struct(cellfun(@(f) fom.material.(f)(index), fn_material, 'UniformOutput', false),fn_material);


    data_vec = get_design_data_vec(geom, material, fsw);
    inductor_compute_obj = design_compute.InductorCompute(n_sol, data_vec, data_const, ann_fem_obj);


    excitation = create_excitation(double(h_convection), double(T_ambient), double(fsw), double(I_L1_rms), double(I_L1_pp), double(duty_cycle), 6910580);
    operating = inductor_compute_obj.get_operating(excitation);

    fn_op = fieldnames(operating);
    T_core_max = operating.(fn_op{1}).thermal.T_core_max;

    L_Loss = operating.(fn_op{1}).losses.P_tot;
    T_max = operating.(fn_op{1}).thermal.T_max;

end
