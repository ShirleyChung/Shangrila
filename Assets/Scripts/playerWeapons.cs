using UnityEngine;
using System.Collections;

public class playerWeapons : MonoBehaviour {
	
	//找到子彈物件
	public GameObject bullets;
	//子彈的傷害
	public float bulletsDamage = 1.0f;
	//子彈速度
	public float bulletsSpeed = 20.0f;
	//子彈射速
	public float bulletsFirerate = 0.3f;
	//子彈重製位置
	public Transform spawnPosition;
	//射擊聲音
	public AudioClip bulletSound;
	
	//各種子彈的變量
	//計時
	private float bulletCounter = 0.0f;
	//位置
	private float bulletPos = 0.0f;
	//目前武器.速度.攻擊力
	private GameObject currentBullet;
	private float currentSpeed;
	private float currentDamage;
	//射速
	private float fireRate = 0.25f;
	private bool dead = false;
	
	void Start () {
		updateBulletType();
	}
	
	void Update () {
		//計時了解甚麼時候可以發射
		bulletCounter += Time.deltaTime;
		//在未死亡的狀態下按下Z鍵是射擊子彈
		if(!dead){
			if(Input.GetKey(KeyCode.Z)){
				if(bulletCounter > fireRate){
					shootBullet();
				}
			}
		}
	}
	
	void shootBullet () {
		//子彈發射的位置
		Vector3 pos = new Vector3(bulletPos+transform.position.x,-0.40f+transform.position.y,0.01f+transform.position.z);
		GameObject bulletPrefab = Instantiate(currentBullet, pos, Quaternion.Euler(0,180,0)) as GameObject;
		bulletPrefab.SendMessage("getDamageAmount", currentDamage, SendMessageOptions.DontRequireReceiver);
		//播放射擊音效
		GetComponent<AudioSource>().PlayOneShot(bulletSound);
		//分辨是朝左還是朝右射擊
		if(spawnPosition.position.x > transform.position.x){
			bulletPrefab.transform.GetComponent<Rigidbody>().velocity = new Vector3(currentSpeed,0,0);
		}else{
			bulletPrefab.transform.GetComponent<Rigidbody>().velocity =  new Vector3(-currentSpeed,0,0);
		}
		bulletCounter = 0.0f;
	}
	//取得武器參數數值
	void updateBulletType () {
		currentBullet = bullets;
		fireRate = bulletsFirerate;
		currentSpeed = bulletsSpeed;
		currentDamage = bulletsDamage;
	}
	

	//如果死掉要將死亡調為成立
	void died () {
		dead = true;
	}
}
