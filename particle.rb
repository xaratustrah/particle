#!/usr/bin/ruby
#
# (c) Copyright M. Shahab SANJARI 2010
#
# this is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# barion is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
#
# along with this software.  If not, see <http://www.gnu.org/licenses/>.


# This porgram calculates the ion data for elements in the AME2003
# table.
#

#--------------------------------------------------------------
class Particle
  C=299792458 #m/s
  U=931.494028 #MeV/C^2
  E=1.602176487e-19 #Coulombs

  attr_accessor :name, :rest_mass_mev, :rest_mass_u, :elcharge, :charge_state,
  :kinetic_energy, :total_kinetic_energy, :gamma, :beta, :freq,
  :harmonic, :momentum, :velocity, :brho,
  :no_of_n, :no_of_p, :mass_excess, :nunbien_per_u,
  :elbien, :relmass, :atomic_number, :center_freq, :circum, :harmonic, :revolution_freq

  def initialize (name)
    
    #General
    @name= name
    @rest_mass_u = 0
    @rest_mass_mev = 0
    @charge_state = 0
    @elcharge= 0
    @color=0
    @weakcharge=0
    @spin=0
    @atomic_number=0
    
    #Nuclear
    @mass_excess=0
    @no_of_n=0
    @no_of_p=0
    @nubien_per_u=0
    @elbien=0
    @isospin=0

    #Relativistic
    @kinetic_energy=0
    @total_kinetic_energy=0
    @gamma=0
    @beta=0
    @velocity=0
    @momentum=0
    @relativistic_mass = 0
    @timedil=0
    @betagamma=0
    @pc=0
    
    #Accelerator
    @freq=0
    @harmonic=0
    @brho=0
    @erho=0
  end
  def calculate
    @rest_mass_mev = to_mev(@rest_mass_u)
    puts 'Name = ' + @atomic_number.to_s + " "+ @name + " " + @charge_state.to_s + '+'
    puts 'Z = ' + no_of_p.to_s
    puts 'N = ' + no_of_n.to_s
    puts 'Mass = ' + rest_mass_u.to_s + ' u'
    puts 'Mass = ' + @rest_mass_mev.to_s + ' MeV/c^2'
    puts 'Mass = ' + to_kg(@rest_mass_mev).to_s + ' kg'
    puts 'Kinetic energy per Nucleon = ' + @kinetic_energy.to_s + ' MeV/u'
    puts 'Total Kinetic energy = ' + (@total_kinetic_energy=@kinetic_energy*atomic_number).to_s + ' MeV'
    puts 'Gamma = ' + (@gamma=@total_kinetic_energy/rest_mass_mev + 1).to_s
    puts 'Beta = ' + (@beta=Math.sqrt(1-1/@gamma**2)).to_s
    puts 'Beta * Gamma = ' + (@beta*@gamma).to_s
    puts 'Velocity = ' + (@velocity=@beta*C).to_s + ' m/s'
    puts 'Relativistic mass = ' + (@relativistic_mass=@rest_mass_mev*@gamma).to_s + ' MeV/c^2'
    puts 'Relativistic mass = ' + to_u(@relativistic_mass).to_s + ' u'
    puts 'Relativistic mass = ' + to_kg(@relativistic_mass).to_s + ' kg'
    puts 'Relativistic momentum = ' + (@momentum=@rest_mass_mev*@beta*@gamma).to_s + ' MeV/c'
    puts 'Relativistic momentum = ' + (@momentum/@atomic_number).to_s + ' MeV/c/u'
    puts 'pc = ' + (@pc=@momentum*C).to_s + ' MeV'
    #puts 'Time dilation factor = '+ (0).to_s
    puts 'Mag. Rigidity = ' +(@brho=@momentum*1e6/@charge_state/C).to_s + ' T/m'
    puts 'Elec. Rigidity = ' + (@erho=@brho*@velocity/1e3).to_s + ' kV'
    puts 'ESR circumference = ' + (@circum = 108.51).to_s + ' m' #108.36 is the central orbit, the other is the injection orbit
    puts 'Resonator center frequency = ' + (@center_freq = 2.44963e+08).to_s + ' Hz'
    puts 'Revolution frequency = ' + (@revolution_freq = @velocity/@circum).to_s + ' Hz'
    puts 'Schottky harmonic = ' + (@harmonic = @center_freq/@revolution_freq).to_s + ' th harmonic'
  end

  def to_u (mev)
    mev/U
  end

  def to_mev(u)
    u*U
  end

  def to_kg (mev)
    mev*1e6*E/C**2
  end

  def to_s
    "This particle is a " + @name + " with a rest_mass of " + @rest_mass_mev.to_s + " MeV"
  end

  def get_el_charge (charge_state)
    charge_state * E
  end

end

#--------------------------------------------------------------

begin 
  raise 'Please specify the nuclide like: 142 Pm 61 400, which means 142Pm 61+ at 400 MeV.' if not ARGV.size == 4

  a=ARGV[0].to_i
  name=ARGV[1].to_s
  ch=ARGV[2].to_i
  e=ARGV[3].to_f

  puts "Nuclear data for " + a.to_s + name + ch.to_s + "+ at " + e.to_s + " MeV/u" 
  puts '--------------------------------------------'

  filename = 'ame03_reduced.csv'
  file = File.new(filename, 'r')
  line=Array.new
  while line=file.gets
    line.chomp!
    line=line.split(',')
    mass_u = line[4].to_f and mass_uu = line[5].to_f and z = line[1].to_i and n = line[0].to_i and break if line[2].to_f == a and line[3]==name	
  end

  mass = (mass_u*1e6 + mass_uu)/1e6

  beam=Particle.new(name)
  beam.atomic_number = a
  beam.no_of_p = z
  beam.no_of_n = n
  beam.charge_state = ch
  beam.rest_mass_u = mass
  beam.kinetic_energy = e
  beam.calculate
rescue Exception => err
  puts "#{err}"
end
