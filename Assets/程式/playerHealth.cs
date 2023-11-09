using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class playerHealth : MonoBehaviour {
	
	//主角的血量
	public int hearts = 6;
	//受到撞擊的聲音
	public AudioClip hitSound;
	//死亡動畫
	public GameObject deathAnim;
	//設置三種血格代表血量的變化
	public Texture full;
	public Texture half;
	public Texture empty;
	//碰到補血道具的音效
	public AudioClip heartSound;
	
	//設置死亡為否
	private bool dead = false;
	//設置可接受傷害為是
	private bool canGetHurt = true;
	//渲染2D圖形
	private SpriteRenderer rend;
	//血量介面
	private Image[] heartsGUI;
	private int health;
	
	void Start () {
		//一個愛心為兩格血量
		health = hearts*2;
		//將血量與GUI介面上的血量做連結
		GameObject getHearts = GameObject.Find("GUI/hearts");
		//得到血量並增加到血量並撥放更新於GUI介面
		getHearts.SendMessage("addHearts", hearts, SendMessageOptions.DontRequireReceiver);
        Image[] allChildren = getHearts.GetComponentsInChildren<Image>();
		heartsGUI = new Image[allChildren.Length];
		health = allChildren.Length*2;
		for(int i = 0;i < allChildren.Length;i++){
			heartsGUI[i] = allChildren[i] as Image;
		}
		rend = GetComponent<SpriteRenderer>();
	}
	//如果在可以接受傷害與非死亡的狀態下受到攻擊
	//播放受傷音效
	//減少血量
	//確認血量並重製可受到傷害
	void takeDamage (int amount) {
		if(canGetHurt && !dead){
			canGetHurt = false;
			GetComponent<AudioSource>().PlayOneShot(hitSound);
			health -= amount;
			StartCoroutine(checkHealth());
			StartCoroutine(resetCanHurt());
		}
	}
	
	//待在怪物或是陷阱上受到傷害
	//這裡設定受到的傷害為1,調到100或許就是所謂的超困難遊戲
	void OnTriggerStay (Collider other){
		if(other.tag == "enemy" || other.tag == "trap"){
			if(canGetHurt && !dead){
				canGetHurt = false;
				GetComponent<AudioSource>().PlayOneShot(hitSound);
				health -= 1;
				StartCoroutine(checkHealth());
				StartCoroutine(resetCanHurt());
			}
		}
		//碰到補血道具要增加血量
		if(other.GetComponent<Collider>().tag == "heart"){
			Destroy(other.gameObject);
			addHealth();
		}
	}
	
	//碰撞到怪物或是陷阱時受到傷害,若只有碰撞傷害若玩家不動就只會觸發一次
	void OnCollisionStay (Collision other){
		if(other.collider.tag == "enemy" || other.collider.tag == "trap"){
			if(canGetHurt && !dead){
				canGetHurt = false;
				GetComponent<AudioSource>().PlayOneShot(hitSound);
				health -= 1;
				StartCoroutine(checkHealth());
				StartCoroutine(resetCanHurt());
			}
		}
	}
	
	//重製可以受到傷害的各種數值與設定
	//受到傷害時變為紅色(1.0f,0.5f,0.5f,1.0f)就是CMYK
	//受到傷害後的無敵時間設為1秒,調到100或許就是所謂的超簡單遊戲
	//結束無敵時間後記得將顏色條回全白,不然就會保持在紅色的狀態
	public IEnumerator resetCanHurt () {
		rend.color = new Vector4(1.0f,0.5f,0.5f,1.0f);
		yield return new WaitForSeconds(1f);
		rend.color = new Vector4(1.0f,1.0f,1.0f,1.0f);
		canGetHurt = true;
	}
	
	//當受到傷害時確認血量
	public IEnumerator checkHealth () {
		//更新血量
		updateHearts();
		// 如果血量少於等於0並且不是死亡的狀態下宣告死亡成立	
		if(health <= 0 && dead == false){
			dead = true;
			//死亡動畫的位置
			Instantiate(deathAnim, transform.position, Quaternion.Euler(0,180,0));
			BroadcastMessage("died", SendMessageOptions.DontRequireReceiver);
			//將2D渲染設為關閉
			var rend = GetComponent<SpriteRenderer>();
			rend.enabled = false;
			//重新復活時間為2秒
			yield return new WaitForSeconds(2);
			//重新讀取關卡
			string lvlName = Application.loadedLevelName;
			Application.LoadLevel(lvlName);
		}
	}
	
	//添加血量
	void addHealth () {
		GetComponent<AudioSource>().PlayOneShot(heartSound);
		//吃到愛心所增加的血量
		health += 2;
		//如果吃的血量超過設定值就不要再增加了
		if(health > 6){
			health = 6;
		}
		//更新血量
		updateHearts();
	}
	
	//更新血量時要更新畫面上玩家的血量
	void updateHearts () {	
		//將血量更新於GUI的血量條上
		for(int i = 0;i < heartsGUI.Length;i++){
			int check = (i+1)*2;
			//如果血格是滿的
			if(check < health+1){
				heartsGUI[i].GetComponent<RawImage>().texture = full;
			}
			//如果血格是半滿
			if(check == health+1){
				heartsGUI[i].GetComponent<RawImage>().texture = half;
			}
			//如果血格是空的
			if(check > health+1){
				heartsGUI[i].GetComponent<RawImage>().texture = empty;
			}
		}
	}
}
