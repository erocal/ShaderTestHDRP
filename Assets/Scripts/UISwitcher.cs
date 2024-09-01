using UnityEngine;
using UnityEngine.UI;

public class UISwitcher : MonoBehaviour
{
    public GameObject panel1;
    public GameObject panel2;

    void Start()
    {
        // 防呆檢查：確保面板物件已設置
        if (panel1 == null || panel2 == null)
        {
            Debug.LogError("Panel1或Panel2未設置。請在檢視器中拖曳對應的面板物件。");
            enabled = false; // 禁用此腳本以防止錯誤操作
            return;
        }
    }

    void Update()
    {
        // 檢測PC上的滑鼠點擊事件
        if (Input.GetMouseButtonDown(0))
        {
            ToggleUI();
        }

        // 檢測手機上的觸摸事件
        if (Input.touchCount > 0)
        {
            Touch touch = Input.GetTouch(0);

            if (touch.phase == TouchPhase.Began)
            {
                ToggleUI();
            }
        }
    }

    void ToggleUI()
    {
        // 防呆檢查：確保兩個面板不相同
        if (panel1 == panel2)
        {
            Debug.LogError("Panel1和Panel2是同一個物件，無法切換。");
            return;
        }

        // 切換兩個面板的顯示狀態
        bool isPanel1Active = panel1.activeSelf;
        panel1.SetActive(!isPanel1Active);
        panel2.SetActive(isPanel1Active);
    }
}
