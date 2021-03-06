#' multi_sims
#'
#' Generate artificial oscillating time series of various types.
#' @param type character indicating which type of time series are to be
#'   generated. Possible values are: "ps": Phase-Shifted plain
#'   sinusoids; "pst": Phase-Shifted plain sinusoids with linear trend over
#'   time; "psd": Phase-Shifted and Damped sinusoids (chirp); "na":
#'   Noisy Amplitude, plain sinusoids with Gaussian white noise; "nad":
#'   Noisy Amplitude Damped, plain sinusoids with Gaussian white noise;
#'   "edls": Exponential Decay Lag Shifted.
#' @param noises numerical vector giving levels of noise to generate the data.
#'   Do not pass 0 (no noise) as this is already generated by default. The
#'   feature controlled by this argument varies across types of simulations.
#'   Phase-Shifted simulations ('psX'): standard deviation of
#'   the Gaussian distribution used to shift the curves. Noisy-Amplitude
#'   simulations ('naX'): standard deviation of the Gaussian distribution used
#'   to generate amplitude noise at each time point. Exponential decay Lag
#'   Shifted: standard deviation of the Gaussian distribution used to generate
#'   the lag between excitation time and response time. Typical values ranges
#'   from 0 to 2.
#' @param n number of trajectories per noise level.
#' @param freq numeric, spacing between 2 time points.
#' @param end numeric, end time of simulations.
#' @param ... Additional arguments specific to simulation type. See
#'   corresponding sim_X functions.
#'
#' @details See ?sim_phase_shifted.
#'
#' @note TODO - function is not optimized: it builds the simulation by growing a
#'   data.table. plot_sim can be used to visualize the output.
#'
#' @seealso plot_sim, sim_phase_shifted, sim_phase_shifted_damped,
#'   sim_phase_shifted_with_fixed_trend, sim_noisy_amplitude,
#'   sim_noisy_amplitude_damped, sim_expodecay_lagged_stim
#' @return a data.table containing the trajectories in long format in 4 columns.
#'   "variable" indicates the ID of the trajectory. IDs are named V1, V2, ...,
#'   Vn for each level of noise.
#' @import data.table
#' @export
#'
#' @examples
#' x <- multi_sims(type = "ps", noises = seq(0.5, 2, 0.5), n = 10, freq = 0.5, end = 30)
#' plot_sim(x)
#'
multi_sims <- function(type, noises, n, freq = 0.2, end = 50, ...){
  # Argument check
  if(!(type %in% c("ps", "pst", "psd", "na", "nad", "edls"))){
    stop("type must be one of c('ps', 'pst', 'psd', 'na', 'nad', 'edls')")
  }
  if(length(type)>1){
    stop("Only one type of simulations can be generated at once. To generate a dataset with more than one type, call mulit_sims twice and bind the outputs.")
  }
  if(0 %in% noises) warning("Trajectories without noise are already generated by default.")

  # Initialize data.table with no noise
  if(type == "ps"){multi_sim <- sim_phase_shifted(noise = 0, n = n, freq = freq, end = end, ...)}
  else if(type == "pst"){multi_sim <- sim_phase_shifted_with_fixed_trend(noise = 0, n = n, freq = freq, end = end, ...)}
  else if(type == "psd"){multi_sim <- sim_phase_shifted_damped(noise = 0, n = n, freq = freq, end = end, ...)}
  else if(type == "na"){multi_sim <- sim_noisy_amplitude(noise = 0, n = n, freq = freq, end = end, ...)}
  else if(type == "nad"){multi_sim <- sim_noisy_amplitude_damped(noise = 0, n = n, freq = freq, end = end, ...)}
  else if(type == "edls"){multi_sim <- sim_expodecay_lagged_stim(noise = 0, n = n, freq = freq, end = end, ...)}

  multi_sim$noise <- 0
  for(noise in noises){
    if(type == "ps"){temp <- sim_phase_shifted(noise = noise, n = n, freq = freq, end = end, ...)}
    else if(type == "pst"){temp <- sim_phase_shifted_with_fixed_trend(noise = noise, n = n, freq = freq, end = end, ...)}
    else if(type == "psd"){temp <- sim_phase_shifted_damped(noise = noise, n = n, freq = freq, end = end, ...)}
    else if(type == "na"){temp <- sim_noisy_amplitude(noise = noise, n = n, freq = freq, end = end, ...)}
    else if(type == "nad"){temp <- sim_noisy_amplitude_damped(noise = noise, n = n, freq = freq, end = end, ...)}
    else if(type == "edls"){temp <- sim_expodecay_lagged_stim(noise = noise, n = n, freq = freq, end = end, ...)}
    temp$noise <- noise
    multi_sim <- rbind(multi_sim, temp)
  }
  return(multi_sim)
}


#' plot_sim
#'
#' Visualize a long data.table such as the one generated by multi_sims.
#' @param data data.table in long format
#' @param x column name of x axis (typically time)
#' @param y column name of y axis (typically measurements)
#' @param group column name of grouping (typically ID of a trajectory)
#' @param use.facet logical, if TRUE use facet to give a second grouping.
#' @param facet column name of second grouping for facetting
#' @param alpha numeric, set transparency of curves
#' @param plot logical, whether to plot the output
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' x <- multi_sims(type = "ps", noises = seq(0.5, 2, 0.5), n = 10, freq = 0.5, end = 30)
#' plot_sim(x)
#'
plot_sim <- function(data, x = "Time", y = "value", group = "variable", use.facet = T, facet = "noise", alpha = 0.2, plot = T){
  require(ggplot2)
  p <- ggplot(data, aes_string(x = x, y = y)) + geom_line(aes_string(group = group), alpha = alpha)
  p <- p + stat_summary(fun.y=mean, geom="line", colour = "blue", size = 1.5)
  if(use.facet){
    p <- p + facet_grid(as.formula(paste(facet, "~ .")))
  }
  if(plot) p
  return(p)
}


#' Simulate oscillating trajectory
#'
#' Set of functions to simulate different types of oscillating trajectories. To
#' generate data with different noise levels, use multi_sim.
#'
#' @param n numeric, number of simulated trajectories
#' @param noise numeric, noise level, see ?multi_sims for details
#' @param freq numeric, spacing between 2 time points.
#' @param end numeric, end time of simulations.
#'
#' @details Damping sinusoids are generated with the equation: \eqn{y(t)=A .
#'   exp(-L.t) . sin(t)}. Where A represents the initial envelope amplitude and
#'   lambda the decay constant. damp_params is of the form: c(A,L)
#'
#'   sim_expodecay_lagged_stim simulates trajectories that arise from a
#'   "stimulation" (i.e. taking the trajectory to a fixed high-level).
#'   Relaxation after stimulation is an exponential decay following equation:
#'   \eqn{y(t) = A0 . exp(-t/T)}. Where A0 represents the initial level of the
#'   trajectory and T the desintegration rate.
#'
#' @return a data.table containing the trajectories in long format in 3 columns.
#'   "variable" indicates the ID of the trajectory.
#' @export
#'
#' @seealso multi_sim
#'
#' @describeIn sim_phase_shifted Phase-Shifted sinusoids
sim_phase_shifted <- function(n, noise, freq = 0.2, end = 50){
  require(data.table)
  # Create a matrix of shifted times
  tvec <- seq(0, end-1, by = freq)
  time_matrix <- matrix(tvec, nrow = length(tvec), ncol = n)
  shifts <- rnorm(n, 0, noise)
  shifts <- matrix(shifts, nrow = length(tvec), ncol = n, byrow = T)
  time_matrix <- time_matrix + shifts

  # Replace each shifted time by it sine function
  sins <- sin(time_matrix)

  # Go to data.table
  sins <- as.data.table(sins)
  sins <- cbind(seq(0, end-1, by = freq), sins)
  colnames(sins)[1] <- "Time"
  # Format long data table
  sins <- melt(sins, id.vars = "Time")
  return(sins)
}

#' @param damp_params numeric vector of 2, for dampening parameters of the form
#'   c(initial amplitude, decay rate). Used in sim_phase_shifted_damped and
#'   sim_noisy_amplitude_damped. See details.
#' @describeIn sim_phase_shifted Damped Phase-Shifted sinusoids (chirp).
#' @export
sim_phase_shifted_damped <- function(n, noise, damp_params, freq = 0.2, end = 50){
  require(data.table)
  # Create a matrix of shifted times
  tvec <- seq(0, end-1, by = freq)
  time_matrix <- matrix(tvec, nrow = length(tvec), ncol = n)
  shifts <- rnorm(n, 0, noise)
  shifts <- matrix(shifts, nrow = length(tvec), ncol = n, byrow = T)
  time_matrix <- time_matrix + shifts

  # Replace each shifted time by it sine function
  sins <- sin(time_matrix) * damp_params[1] * exp(-damp_params[2]*time_matrix)

  # Go to data.table
  sins <- as.data.table(sins)
  sins <- cbind(seq(0, end-1, by = freq), sins)
  colnames(sins)[1] <- "Time"
  # Format long data table
  sins <- melt(sins, id.vars = "Time")
  return(sins)
}


#' @param slope numeric, slope of linear trend, i.e. change of mean value per
#'   unit of time.
#' @describeIn sim_phase_shifted Phase-Shifted sinusoids with linear trend.
#' @export
sim_phase_shifted_with_fixed_trend <- function(n, noise, slope, freq = 0.2, end = 50){
  # Add a trend, i.e. a linear increase or decrease, to simulations
  # See sim_phase_shifted for arguments. Slope indicates the slope of the trend
  require(data.table)
  sins <- sim_phase_shifted(n, noise, freq, end)
  trend_vec <- unique(sins$Time)
  trend_vec <- trend_vec * slope
  sins[, value := value + trend_vec, by = .(variable)]
  return(sins)
}


#' @describeIn sim_phase_shifted Sinusoids with Gaussian white noise in amplitude.
#' @export
sim_noisy_amplitude <- function(n, noise, freq = 0.2, end = 50){
  require(data.table)
  # Create a matrix of times and noise
  tvec <- seq(0, end-1, by = freq)
  time_matrix <- matrix(tvec, nrow = length(tvec), ncol = n)
  noise_matrix <- replicate(n, rnorm(length(tvec), 0, noise))

  # Replace each shifted time by it sine function and add white noise
  sins <- sin(time_matrix)
  sins <- sins + noise_matrix

  # Go to data.table
  sins <- as.data.table(sins)
  sins <- cbind(seq(0, end-1, by = freq), sins)
  colnames(sins)[1] <- "Time"
  # Format long data table
  sins <- melt(sins, id.vars = "Time")
  return(sins)
}


#' @describeIn sim_phase_shifted Damped sinusoids with Gaussian white noise in amplitude.
#' @export
sim_noisy_amplitude_damped <- function(n, noise, damp_params, freq = 0.2, end = 50){
  require(data.table)
  # Create a matrix of times and noise
  tvec <- seq(0, end-1, by = freq)
  time_matrix <- matrix(tvec, nrow = length(tvec), ncol = n)
  noise_matrix <- replicate(n, rnorm(length(tvec), 0, noise))

  # Replace each shifted time by it sine function
  sins <- sin(time_matrix) * damp_params[1] * exp(-damp_params[2]*time_matrix)
  sins <- sins + noise_matrix

  # Go to data.table
  sins <- as.data.table(sins)
  sins <- cbind(seq(0, end-1, by = freq), sins)
  colnames(sins)[1] <- "Time"
  # Format long data table
  sins <- melt(sins, id.vars = "Time")
  return(sins)
}


#' @param interval.stim Time interval between stimulations. Used in
#'   sim_expodecay_lagged_stim only.
#' @param lambda Desintegration rate. Used in sim_expodecay_lagged_stim only.
#'   See details.
#' @describeIn sim_phase_shifted Lagged Exponential Decays.
#' @export
sim_expodecay_lagged_stim <- function(n, noise, interval.stim = 5, lambda = 0.2, freq = 0.2, end = 50){
  require(data.table)
  # Time vector
  tvec <- seq(0, end-1, by = freq)
  # Matrix with stimulation times
  stim_time <- seq(interval.stim, end-1 , interval.stim)
  stim_time_matrix <- matrix(stim_time, nrow = length(stim_time), ncol = n)

  # Randomize the stimulation times (represent random lag), forbid lag < 0
  noise_matrix <- abs(replicate(n, rnorm(n = length(stim_time), mean = 0, sd = noise)))
  stim_time_matrix <- stim_time_matrix + noise_matrix

  # Initialize trajectories with 0 everywhere, set to 1 at stimulus times
  trajs <- matrix(0, nrow = length(tvec), ncol = n)
  for(col in 1:ncol(stim_time_matrix)){
    for(row in 1:nrow(stim_time_matrix)){
      index <- which(tvec >= stim_time_matrix[row, col])[1]
      trajs[index, col] <- 1
    }
  }

  # Expo decay computed thanks to previous value
  decrease_factor <- exp(-lambda * freq)
  for(col in 1:ncol(trajs)){
    for(row in 2:nrow(trajs)){
      # If not at a stim time, decay
      if(trajs[row, col] != 1){trajs[row, col] <- trajs[row-1, col] * decrease_factor}
    }
  }

  # Go to data.table
  trajs <- as.data.table(trajs)
  trajs <- cbind(seq(0, end-1, by = freq), trajs)
  colnames(trajs)[1] <- "Time"
  # Format long data table
  trajs <- melt(trajs, id.vars = "Time")
  return(trajs)
}

