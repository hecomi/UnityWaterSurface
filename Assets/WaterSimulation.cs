using System.Collections.Generic;
using UnityEngine;

public class WaterSimulation : MonoBehaviour
{
    public enum Mode
    {
        Update = 0,
        PushDown = 1,
        PushUp = 2
    }
    
    [SerializeField]
    CustomRenderTexture texture;

    [SerializeField]
    int iterationPerFrame = 5;

    [SerializeField, Range(0f, 1f)] 
    private float clickRadius = 0.05f;

    [SerializeField] 
    private LayerMask clickLayerMask = new LayerMask();

    private List<CustomRenderTextureUpdateZone> updateZones;
    private CustomRenderTextureUpdateZone defaultZone;

    void Start()
    {
        updateZones = new List<CustomRenderTextureUpdateZone>();
        
        defaultZone = new CustomRenderTextureUpdateZone();
        defaultZone.needSwap = true;
        defaultZone.passIndex = 0;
        defaultZone.rotation = 0f;
        defaultZone.updateZoneCenter = new Vector2(0.5f, 0.5f);
        defaultZone.updateZoneSize = new Vector2(1f, 1f);

        texture.Initialize();
    }

    private void FixedUpdate()
    {
        texture.ClearUpdateZones();
        updateZones.Add(defaultZone);
        UpdateMouseClickZones();
        UpdateZones();
        updateZones.Clear();
        
        texture.Update(iterationPerFrame);
    }

    private void UpdateMouseClickZones()
    {
        bool leftClick = Input.GetMouseButton(0);
        bool rightClick = Input.GetMouseButton(1);
        if (!leftClick && !rightClick) return;

        RaycastHit hit;
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray, out hit, 100f, clickLayerMask, QueryTriggerInteraction.Ignore))
        {
            var normalizedCoordinate = new Vector2(hit.textureCoord.x, 1f - hit.textureCoord.y);
            var size = new Vector2(clickRadius, clickRadius);
            var mode = leftClick ? Mode.PushDown : Mode.PushUp;

            AddZone(mode, normalizedCoordinate, size);
        }
    }

    public void AddZone(Mode mode, Vector2 normalizedCoordinate, Vector2 size)
    {
        var zone = new CustomRenderTextureUpdateZone();
        zone.needSwap = true;
        zone.passIndex = (int) mode;
        zone.rotation = 0f;
        zone.updateZoneCenter = normalizedCoordinate;
        zone.updateZoneSize = size;
            
        updateZones.Add(zone);
    }
    
    private void UpdateZones()
    {
        if (updateZones.Count <= 1)
        {
            return;
        }
        
        texture.SetUpdateZones(updateZones.ToArray());
    }
}