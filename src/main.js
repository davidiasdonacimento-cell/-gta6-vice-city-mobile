import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { Sky } from 'three/addons/objects/Sky.js';
import './style.css';

const root = document.querySelector('#game');
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x8ac6d1);
scene.fog = new THREE.FogExp2(0x9bcbd0, 0.000105);
const camera = new THREE.PerspectiveCamera( sixty(), innerWidth/innerHeight, .1, 18000);
const renderer = new THREE.WebGLRenderer({antialias:true, powerPreference:'high-performance'});
renderer.setPixelRatio(Math.min(devicePixelRatio,1.6));
renderer.setSize(innerWidth,innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.12;
root.appendChild(renderer.domElement);
function sixty(){return  sixtyValue()}
function sixtyValue(){return 60}

const hemi = new THREE.HemisphereLight(0xc9f4ff,0x40564c,2.0); scene.add(hemi);
const sun = new THREE.DirectionalLight(0xffe1bd,3.1); sun.position.set(-900,1300,700); sun.castShadow=true; sun.shadow.mapSize.set(2048,2048); sun.shadow.camera.left=-1100;sun.shadow.camera.right=1100;sun.shadow.camera.top=1100;sun.shadow.camera.bottom=-1100;scene.add(sun);
const sky = new Sky(); sky.scale.setScalar(12000); sky.material.uniforms.turbidity.value=7;sky.material.uniforms.rayleigh.value=1.8;sky.material.uniforms.mieCoefficient.value=.004;scene.add(sky);
const waterMat=new THREE.MeshStandardMaterial({color:0x168ca1,roughness:.28,metalness:.15});
const ocean=new THREE.Mesh(new THREE.PlaneGeometry(16000,16000),waterMat);ocean.rotation.x=-Math.PI/2;ocean.position.y=-5;scene.add(ocean);
const islandMat=new THREE.MeshStandardMaterial({color:0xcbbd91,roughness:1});
const island=new THREE.Mesh(new THREE.CircleGeometry(5200,160),islandMat);island.rotation.x=-Math.PI/2;island.position.y=-4.8;scene.add(island);
const grass=new THREE.Mesh(new THREE.CircleGeometry(4400,160),new THREE.MeshStandardMaterial({color:0x648b61,roughness:1}));grass.rotation.x=-Math.PI/2;grass.position.y=-4.5;scene.add(grass);

const roadMat=new THREE.MeshStandardMaterial({color:0x303b40,roughness:.92});
const lineMat=new THREE.MeshStandardMaterial({color:0xe7d6a0,roughness:.8});
const sidewalkMat=new THREE.MeshStandardMaterial({color:0xb9b4a2,roughness:1});
const roadPaths=[];
function road(points,width=22){
 roadPaths.push(points);
 const curve=new THREE.CatmullRomCurve3(points.map(p=>new THREE.Vector3(p[0],-.15,p[1])));
 const segments=Math.max(100,points.length*24);
 function ribbon(halfWidth,y,material){
  const positions=[],uv=[],indices=[];
  for(let i=0;i<=segments;i++){
   const t=i/segments,p=curve.getPointAt(t),tangent=curve.getTangentAt(t);
   const side=new THREE.Vector3(-tangent.z,0,tangent.x).normalize();
   const left=p.clone().addScaledVector(side,halfWidth);const right=p.clone().addScaledVector(side,-halfWidth);
   left.y=y;right.y=y;
   positions.push(left.x,left.y,left.z,right.x,right.y,right.z);uv.push(0,t*8,1,t*8);
   if(i<segments){const n=i*2;indices.push(n,n+1,n+2,n+1,n+3,n+2);}
  }
  const geometry=new THREE.BufferGeometry();
  geometry.setAttribute('position',new THREE.Float32BufferAttribute(positions,3));
  geometry.setAttribute('uv',new THREE.Float32BufferAttribute(uv,2));
  geometry.setIndex(indices);geometry.computeVertexNormals();
  const mesh=new THREE.Mesh(geometry,material);mesh.receiveShadow=true;scene.add(mesh);
 }
 ribbon(width/2+2.5,-.36,sidewalkMat);
 ribbon(width/2,-.12,roadMat);
}
const boulevard=[[-3600,-500],[-2700,-650],[-1700,-550],[-700,-700],[400,-520],[1500,-650],[2600,-500],[3500,-250]];
road(boulevard,34);
road([[-2600,-2600],[-2200,-1700],[-1800,-700],[-1500,400],[-1250,1600],[-900,2600]],28);
road([[2200,-2800],[1900,-1700],[1500,-650],[1300,500],[1100,1700],[700,2900]],30);
road([[-3000,1800],[-2000,1500],[-900,1450],[200,1650],[1300,1500],[2500,1100],[3200,700]],25);
road([[-2800,-2300],[-1700,-2100],[-500,-2200],[700,-2100],[1900,-2200],[2800,-2500]],24);
road([[-500,-3400],[-300,-2300],[-100,-1200],[100,0],[350,1200],[600,2300],[800,3400]],22);

const buildingMats=[0xd8c6a6,0xe6dfd0,0xb8c8c7,0xe1a98d,0x9db5bb,0xd7b1a9,0x8ba4a5].map(c=>new THREE.MeshStandardMaterial({color:c,roughness:.78}));
const glassMats=[0x39717c,0x4e8290,0x254b5a].map(c=>new THREE.MeshStandardMaterial({color:c,metalness:.45,roughness:.24}));
function makeBuilding(x,z,index){
 const h=30+rand()*112;
 const radius=13+rand()*13;
 const group=new THREE.Group();group.position.set(x,0,z);
 const mat=buildingMats[index%buildingMats.length];
 const profile=[
  new THREE.Vector2(0,0),
  new THREE.Vector2(radius*.86,0),
  new THREE.Vector2(radius,h*.07),
  new THREE.Vector2(radius*.96,h*.72),
  new THREE.Vector2(radius*.82,h*.91),
  new THREE.Vector2(radius*.68,h),
  new THREE.Vector2(0,h)
 ];
 const body=new THREE.Mesh(new THREE.LatheGeometry(profile,32),mat);
 body.castShadow=true;body.receiveShadow=true;group.add(body);
 const floorCount=Math.max(2,Math.floor(h/9));
 for(let floor=1;floor<floorCount;floor++){
  const y=h*floor/floorCount;
  const glass=new THREE.Mesh(new THREE.CylinderGeometry(radius*.986,radius*.986,.85,32),glassMats[index%3]);
  glass.position.y=y;group.add(glass);
  const ledge=new THREE.Mesh(new THREE.TorusGeometry(radius*.99,.24,5,32),new THREE.MeshStandardMaterial({color:0xd8d0bd,roughness:.8}));
  ledge.rotation.x=Math.PI/2;ledge.position.y=y+.55;group.add(ledge);
 }
 const roof=new THREE.Mesh(new THREE.CylinderGeometry(radius*.68,radius*.82,2.2,32),mat);
 roof.position.y=h+.8;roof.castShadow=true;group.add(roof);
 const rooftop=new THREE.Mesh(new THREE.CylinderGeometry(radius*.22,radius*.25,3.5,20),glassMats[(index+1)%3]);
 rooftop.position.y=h+3.5;group.add(rooftop);
 scene.add(group);buildingPositions.push({x,z,r:radius});
 return group;
}
// City blocks are placed along a curved street grid, with rounded towers and varied rooflines.
let seed=81723;function rand(){seed=(seed*1664525+1013904223)>>>0;return seed/4294967296}
const buildingPositions=[];let buildingIndex=0;
for(let z=-3000;z<=3000;z+=210){
 for(let x=-3200;x<=3200;x+=230){
  if(Math.abs(x)<380&&Math.abs(z)<400)continue;
  if(Math.abs(z+500)<100||Math.abs(x+1500)<90||Math.abs(x-1300)<90||Math.abs(z-1500)<90)continue;
  if(Math.hypot(x,z)>3900)continue;
  const bx=x+(rand()-.5)*85,bz=z+(rand()-.5)*85;
  if(rand()<.16){makeBuilding(bx,bz,buildingIndex++);if(rand()>.45)makeBuilding(bx+58,bz+42,buildingIndex++);}
 }
}
// Palm trees: curved trunks and layered fronds, not primitive block scenery.
const trunkMat=new THREE.MeshStandardMaterial({color:0x79533a,roughness:1});
const leafMat=new THREE.MeshStandardMaterial({color:0x267b56,roughness:.8,side:THREE.DoubleSide});
function palm(x,z,s=1){
 const g=new THREE.Group();g.position.set(x,0,z);
 const trunk=new THREE.Mesh(new THREE.CylinderGeometry(.22*s,.42*s,8*s,9),trunkMat);trunk.position.y=4*s;trunk.rotation.z=.06;trunk.castShadow=true;g.add(trunk);
 for(let i=0;i<8;i++){const a=i*Math.PI/4;const leaf=new THREE.Mesh(new THREE.ConeGeometry(.42*s,6*s,5,1,true),leafMat);leaf.position.set(Math.cos(a)*2.1*s,8*s+Math.sin(i*2)*.25,Math.sin(a)*2.1*s);leaf.rotation.z=-Math.cos(a)*.85;leaf.rotation.x=Math.sin(a)*.85;leaf.rotation.y=-a;leaf.castShadow=true;g.add(leaf);}
 scene.add(g);
}
for(let i=0;i<270;i++){const a=rand()*Math.PI*2,r=800+rand()*3000;palm(Math.cos(a)*r,Math.sin(a)*r,.7+rand()*.65);}

const player=new THREE.Group();player.position.set(0,0,0);scene.add(player);
let avatar=null,mixer=null,actions={},activeAction=null;
const loader=new GLTFLoader();
loader.load('https://threejs.org/examples/models/gltf/Soldier.glb',g=>{
 avatar=g.scene;avatar.scale.setScalar(2.05);avatar.position.y=0;avatar.traverse(o=>{if(o.isMesh){o.castShadow=true;o.frustumCulled=true;}});player.add(avatar);
 mixer=new THREE.AnimationMixer(avatar);
 for(const clip of g.animations){const action=mixer.clipAction(clip);actions[clip.name]=action;}
 setAction('Idle');
},undefined,()=>{document.querySelector('#hint').textContent='Modelo 3D externo indisponível; confira sua conexão.';});
function setAction(name){const next=actions[name];if(!next||activeAction===next)return;next.reset().fadeIn(.2).play();if(activeAction)activeAction.fadeOut(.2);activeAction=next;}

const car=new THREE.Group();car.position.set(55,0,45);scene.add(car);
function carProfile(points,depth,material,y){
 const shape=new THREE.Shape();shape.moveTo(points[0][0],points[0][1]);for(let i=1;i<points.length;i++)shape.lineTo(points[i][0],points[i][1]);shape.closePath();
 const geometry=new THREE.ExtrudeGeometry(shape,{depth,bevelEnabled:true,bevelSegments:3,steps:1,bevelSize:.16,bevelThickness:.14,curveSegments:10});geometry.translate(0,0,-depth/2);geometry.center();
 const mesh=new THREE.Mesh(geometry,material);mesh.rotation.y=Math.PI/2;mesh.position.y=y;mesh.castShadow=true;return mesh;
}
car.add(carProfile([[-5,.5],[-4.7,1.1],[-3.6,1.45],[3.8,1.45],[4.8,1.05],[5,.55]],5.5,new THREE.MeshPhysicalMaterial({color:0xe75e72,metalness:.35,roughness:.25,clearcoat:1}),1.05));
car.add(carProfile([[-2.8,1.45],[-1.9,2.55],[1.8,2.55],[3,1.45]],4.25,new THREE.MeshPhysicalMaterial({color:0x294a54,metalness:.45,roughness:.2,transparent:true,opacity:.88}),1.08));
for(const x of [-2.7,2.7])for(const z of [-3.2,3.2]){const wheel=new THREE.Mesh(new THREE.CylinderGeometry(.78,.78,.42,18),new THREE.MeshStandardMaterial({color:0x15191b,roughness:.9}));wheel.rotation.z=Math.PI/2;wheel.position.set(x,.8,z);car.add(wheel);}
let driving=false,speed=0;
const keys={};addEventListener('keydown',e=>{keys[e.key.toLowerCase()]=true;if(e.key==='Shift')running=true;if(e.key.toLowerCase()==='e')toggleCar();});
addEventListener('keyup',e=>{keys[e.key.toLowerCase()]=false;if(e.key==='Shift')running=false;});
let running=false,joy={x:0,y:0};
const zone=document.querySelector('#stick-zone'),base=document.querySelector('#stick-base'),knob=document.querySelector('#stick-knob');
let pointer=null;
function moveStick(e){
 const r=base.getBoundingClientRect(),cx=r.left+r.width/2,cy=r.top+r.height/2;
 let dx=e.clientX-cx,dy=e.clientY-cy;
 const max=Math.max(20,(r.width-49)/2),len=Math.hypot(dx,dy)||1;
 if(len>max){dx=dx/len*max;dy=dy/len*max;}
 joy.x=THREE.MathUtils.clamp(dx/max,-1,1);
 joy.y=THREE.MathUtils.clamp(dy/max,-1,1);
 knob.style.transform=`translate3d(${dx}px,${dy}px,0)`;
}
function releaseStick(){
 pointer=null;joy.x=0;joy.y=0;knob.style.transform='translate3d(0,0,0)';
}
zone.addEventListener('pointerdown',e=>{
 e.preventDefault();pointer=e.pointerId;
 try{zone.setPointerCapture(pointer);}catch{}
 moveStick(e);
});
zone.addEventListener('pointermove',e=>{if(e.pointerId===pointer){e.preventDefault();moveStick(e);}});
zone.addEventListener('pointerup',e=>{if(e.pointerId===pointer)releaseStick();});
zone.addEventListener('pointercancel',releaseStick);
zone.addEventListener('lostpointercapture',releaseStick);
document.querySelector('#run-btn').addEventListener('pointerdown',()=>running=true);
['pointerup','pointercancel','pointerleave'].forEach(ev=>document.querySelector('#run-btn').addEventListener(ev,()=>running=false));
document.querySelector('#enter-btn').addEventListener('click',toggleCar);
function toggleCar(){if(!driving&&player.position.distanceTo(car.position)<24){driving=true;player.visible=false;document.querySelector('#hint').textContent='Você entrou no veículo · toque ENTRAR para sair';}else if(driving){driving=false;player.visible=true;player.position.copy(car.position).add(new THREE.Vector3(8,0,0));document.querySelector('#hint').textContent='Explore Vice City';}}
let cameraYaw=0,cameraPitch=.28,drag=null,lastX=0,lastY=0;
renderer.domElement.addEventListener('pointerdown',e=>{if(e.clientX<innerWidth*.38&&e.clientY>innerHeight*.55)return;drag=e.pointerId;lastX=e.clientX;lastY=e.clientY;renderer.domElement.setPointerCapture(drag);});
renderer.domElement.addEventListener('pointermove',e=>{if(drag!==e.pointerId)return;cameraYaw-=(e.clientX-lastX)*.005;cameraPitch=THREE.MathUtils.clamp(cameraPitch+(e.clientY-lastY)*.003,-.05,.85);lastX=e.clientX;lastY=e.clientY;});
function stopDrag(){drag=null;}renderer.domElement.addEventListener('pointerup',stopDrag);renderer.domElement.addEventListener('pointercancel',stopDrag);

const mini=document.querySelector('#minimap'),ctx=mini.getContext('2d');
function drawMap(focus=new THREE.Vector3()){
 const size=180,center=size/2,scale=.033;
 ctx.clearRect(0,0,size,size);
 ctx.fillStyle='#0b3440';ctx.fillRect(0,0,size,size);
 const px=x=>center+(x-focus.x)*scale;
 const py=z=>center+(z-focus.z)*scale;
 ctx.beginPath();ctx.arc(px(0),py(0),5200*scale,0,Math.PI*2);
 ctx.fillStyle='#526e57';ctx.fill();
 ctx.strokeStyle='#d7c59a';ctx.lineWidth=2.5;ctx.stroke();
 ctx.save();ctx.beginPath();ctx.arc(center,center,88,0,Math.PI*2);ctx.clip();
 for(const path of roadPaths){
  ctx.beginPath();
  path.forEach((p,i)=>{const x=px(p[0]),y=py(p[1]);if(i===0)ctx.moveTo(x,y);else ctx.lineTo(x,y);});
  ctx.strokeStyle='#b8b5a7';ctx.lineWidth=4.2;ctx.lineCap='round';ctx.lineJoin='round';ctx.stroke();
  ctx.beginPath();
  path.forEach((p,i)=>{const x=px(p[0]),y=py(p[1]);if(i===0)ctx.moveTo(x,y);else ctx.lineTo(x,y);});
  ctx.strokeStyle='#39464a';ctx.lineWidth=2.8;ctx.stroke();
 }
 for(const b of buildingPositions){
  const x=px(b.x),y=py(b.z);
  if(x<0||x>size||y<0||y>size)continue;
  ctx.fillStyle='#d8c6a6';ctx.beginPath();ctx.arc(x,y,Math.max(1.1,b.r*scale*.42),0,Math.PI*2);ctx.fill();
 }
 ctx.restore();
 ctx.save();ctx.translate(center,center);ctx.rotate(-focus.rotationY||0);
 ctx.beginPath();ctx.moveTo(0,-8);ctx.lineTo(5.5,6);ctx.lineTo(0,3.5);ctx.lineTo(-5.5,6);ctx.closePath();
 ctx.fillStyle='#71fff0';ctx.fill();ctx.lineWidth=1.5;ctx.strokeStyle='#09252c';ctx.stroke();
 ctx.restore();
}
drawMap();
const clockEl=document.querySelector('#clock');const clockStart=performance.now();
const clock=new THREE.Clock();
function animate(){
 requestAnimationFrame(animate);const dt=Math.min(clock.getDelta(),.04);if(mixer)mixer.update(dt);
 const forward=(keys.w||keys.arrowup?-1:0)+(keys.s||keys.arrowdown?1:0)+joy.y;
 const side=(keys.d||keys.arrowright?1:0)-(keys.a||keys.arrowleft?1:0)+joy.x;
 const moving=Math.abs(forward)+Math.abs(side)>.08;
 if(driving){const throttle=-forward;speed=THREE.MathUtils.damp(speed,throttle*105,2.2,dt);car.rotation.y-=side*dt*1.7;car.translateZ(-speed*dt);}
 else if(moving){const direction=new THREE.Vector3(side,0,forward).normalize().applyAxisAngle(new THREE.Vector3(0,1,0),cameraYaw);const pace=(running?82:42)*dt;player.position.addScaledVector(direction,pace);player.rotation.y=Math.atan2(direction.x,direction.z);setAction(running?'Run':'Walk');}
 else setAction('Idle');
 const target=driving?car.position:player.position;
 const distance=driving?27:18;
 const offset=new THREE.Vector3(Math.sin(cameraYaw)*distance,7+cameraPitch*12,Math.cos(cameraYaw)*distance);
 camera.position.lerp(target.clone().add(offset),1-Math.exp(-5*dt));camera.lookAt(target.x,target.y+3,target.z);
 const elapsed=(performance.now()-clockStart)/1000;const mins=Math.floor((12*60+elapsed*.7)%1440);clockEl.textContent=String(Math.floor(mins/60)).padStart(2,'0')+':'+String(mins%60).padStart(2,'0');
 drawMap(target);
 renderer.render(scene,camera);
}
animate();
document.querySelector('#loading').style.opacity='0';setTimeout(()=>document.querySelector('#loading')?.remove(),650);
addEventListener('resize',()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight);renderer.setPixelRatio(Math.min(devicePixelRatio,1.6));});