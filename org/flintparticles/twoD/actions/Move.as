/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord (Big Room)
 * Copyright (c) Big Room Ventures Ltd. 2008
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.flintparticles.twoD.actions 
{
	import org.flintparticles.common.actions.ActionBase;
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.twoD.particles.Particle2D;	

	/**
	 * The Move action updates the position of the particle based on its velocity.
	 * It uses a Euler integrator to calculate the new position. If you want an
	 * emitter's particles to move then you must add a Move action, or a similar 
	 * custom action, to the emitter
	 */
	public class Move extends ActionBase
	{
		private var p:Particle2D;
		/**
		 * The constructor creates a Move action for use by an emitter. 
		 * To add a Move to all particles created by an emitter, use the
		 * emitter's addAction method.
		 * 
		 * @see org.flintparticles.common.emitters.Emitter#addAction()
		 */
		public function Move()
		{
		}
		
		/**
		 * Returns a value of -10, so that the Move action executes 
		 * after most other actions, particularly after actions that change the
		 * particle's velocity like Accelerate.
		 * 
		 * @see org.flintparticles.common.actions.Action#getDefaultPriority()
		 */
		override public function getDefaultPriority():Number
		{
			return -10;
		}

		/**
		 * Updates the particle's position based on its velocity and the period of 
		 * time indicated.
		 * 
		 * <p>This method is called by the emitter and need not be called by the 
		 * user.</p>
		 * 
		 * @param emitter The Emitter that created the particle.
		 * @param particle The particle to be updated.
		 * @param time The duration of the frame - used for time based updates.
		 * 
		 * @see org.flintparticles.common.actions.Action#update()
		 */
		override public function update( emitter:Emitter, particle:Particle, time:Number ):void
		{
			p = Particle2D( particle );
			p.x += p.velX * time;
			p.y += p.velY * time;
		}
	}
}
